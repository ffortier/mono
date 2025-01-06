use std::{collections::HashSet, iter::Peekable};

use crate::error::{Error, Result};

#[derive(Debug, PartialEq, Eq, Hash, Clone)]
pub enum Token {
    Capturing(Box<Token>, Option<String>),
    Conjunction(Vec<Token>),
    Disjunction(Vec<Token>),
    Literal(char),
    Start,
    End,
    Any,
    GreedyQuantifier(Box<Token>, usize, Option<usize>),
    LazyQuantifier(Box<Token>, usize, Option<usize>),
    WordBoundary,
    Alphanumeric,
    Digit,
    Whitespace,
    NotAlphanumeric,
    NotDigit,
    NotWhitespace,
    AsciiRange(char, char),
}

pub fn parse_expr(expr: impl IntoIterator<Item = char>) -> Result<Token> {
    let mut chars = expr.into_iter().enumerate().peekable();
    let mut tokens = vec![];
    let mut disjunction = vec![];

    loop {
        match chars.next() {
            Some((_, '|')) => disjunction.push(Token::Conjunction(tokens.drain(..).collect())),
            Some((i, ch)) => tokens.push(parse_next(ch, i, &mut chars)?),
            None => break,
        };
    }

    if disjunction.is_empty() {
        Ok(Token::Conjunction(tokens))
    } else {
        disjunction.push(Token::Conjunction(tokens.drain(..).collect()));
        Ok(Token::Disjunction(disjunction))
    }
}

fn parse_next(
    ch: char,
    position: usize,
    chars: &mut Peekable<impl Iterator<Item = (usize, char)>>,
) -> Result<Token> {
    let tok = match ch {
        '?' | '*' | '+' | '{' => return Err(Error::UnexpectedChar(ch, position)),
        '^' => Token::Start,
        '$' => Token::End,
        '.' => Token::Any,
        '\\' => parse_special(chars)?,
        '(' => parse_group(chars)?,
        '[' => parse_choice(chars)?,
        _ => Token::Literal(ch),
    };

    parse_modifier(chars, tok)
}

fn parse_group(chars: &mut Peekable<impl Iterator<Item = (usize, char)>>) -> Result<Token> {
    let mut capturing = true;
    let mut name = None;

    if let Some(_) = chars.next_if(|(_, ch)| *ch == '?') {
        if let Some(_) = chars.next_if(|(_, ch)| *ch == '<') {
            name = Some(parse_group_name(chars)?);
        } else if let Some(_) = chars.next_if(|(_, ch)| *ch == ':') {
            capturing = false;
        }
    }

    let mut tokens = vec![];
    let mut disjunction = vec![];

    loop {
        match chars.next() {
            None => return Err(Error::UnexpectedEndOfInput),
            Some((_, ')')) => break,
            Some((_, '|')) => disjunction.push(Token::Conjunction(tokens.drain(..).collect())),
            Some((i, ch)) => tokens.push(parse_next(ch, i, chars)?),
        };
    }

    let mut tok = if disjunction.is_empty() {
        Token::Conjunction(tokens)
    } else {
        disjunction.push(Token::Conjunction(tokens.drain(..).collect()));
        Token::Disjunction(disjunction)
    };

    if capturing {
        tok = Token::Capturing(Box::new(tok), name);
    }

    Ok(tok)
}

fn parse_group_name(chars: &mut impl Iterator<Item = (usize, char)>) -> Result<String> {
    let mut buf = String::new();

    loop {
        match chars.next() {
            None => return Err(Error::UnexpectedEndOfInput),
            Some((pos, '>')) if buf.is_empty() => return Err(Error::UnexpectedChar('>', pos)),
            Some((_, '>')) => return Ok(buf),
            Some((_, ch)) => buf.push(ch),
        };
    }
}

fn parse_modifier(
    chars: &mut Peekable<impl Iterator<Item = (usize, char)>>,
    tok: Token,
) -> Result<Token> {
    if let Some((_, ch)) = chars.next_if(|(_, ch)| "?*+{".contains(*ch)) {
        let new_tok = match ch {
            '?' => Token::GreedyQuantifier(Box::new(tok), 0, Some(1)),
            '*' => match chars.next_if(|(_, ch)| *ch == '?') {
                Some(_) => Token::LazyQuantifier(Box::new(tok), 0, None),
                None => Token::GreedyQuantifier(Box::new(tok), 0, None),
            },
            '+' => match chars.next_if(|(_, ch)| *ch == '?') {
                Some(_) => Token::LazyQuantifier(Box::new(tok), 1, None),
                None => Token::GreedyQuantifier(Box::new(tok), 1, None),
            },
            '{' => {
                let (min, max) = parse_range_quantifier(chars)?;

                match chars.next_if(|(_, ch)| *ch == '?') {
                    Some(_) => Token::LazyQuantifier(Box::new(tok), min, max),
                    None => Token::GreedyQuantifier(Box::new(tok), min, max),
                }
            }
            _ => panic!("Impossible! validated in the outer next_if"),
        };

        Ok(new_tok)
    } else {
        Ok(tok)
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum ChoiceToken {
    Token(Token),
    Literal(char),
    RangeStart(char),
}

fn parse_choice(chars: &mut impl Iterator<Item = (usize, char)>) -> Result<Token> {
    let mut choices = HashSet::new();
    let mut last = None;

    loop {
        let tok = match chars.next() {
            Some((_, ']')) => {
                if let Some(ChoiceToken::RangeStart(_)) = last {
                    choices.insert(Token::Literal('-'));
                }
                break;
            }
            Some((_, '\\')) => ChoiceToken::Token(parse_special(chars)?),
            Some((_, '-')) => match last {
                Some(ChoiceToken::Literal(ch)) => ChoiceToken::RangeStart(ch),
                Some(ChoiceToken::Token(Token::Literal(ch))) => ChoiceToken::RangeStart(ch),
                _ => ChoiceToken::Literal('-'),
            },
            Some((_, ch)) => ChoiceToken::Literal(ch),
            None => return Err(Error::UnexpectedEndOfInput),
        };

        match tok.clone() {
            ChoiceToken::Literal(ch) | ChoiceToken::Token(Token::Literal(ch)) => {
                if let Some(ChoiceToken::RangeStart(start)) = last {
                    choices.remove(&Token::Literal(start));
                    choices.insert(Token::AsciiRange(start, ch));
                } else {
                    choices.insert(Token::Literal(ch));
                }
            }
            ChoiceToken::Token(tok) => {
                choices.insert(tok);
            }
            _ => {}
        };

        last = Some(tok);
    }

    Ok(Token::Disjunction(choices.into_iter().collect()))
}

fn parse_range_quantifier(
    chars: &mut impl Iterator<Item = (usize, char)>,
) -> Result<(usize, Option<usize>)> {
    let mut quantities: Vec<Option<usize>> = vec![];
    let mut buf = String::new();

    loop {
        match chars.next() {
            Some((pos, '}')) => {
                quantities.push(buf.parse::<usize>().ok());

                return match quantities.len() {
                    1 => Ok((
                        quantities
                            .get(0)
                            .unwrap()
                            .ok_or(Error::UnexpectedChar('}', pos))?,
                        *quantities.get(0).unwrap(),
                    )),
                    2 => Ok((
                        quantities.get(0).unwrap().unwrap_or_default(),
                        *quantities.get(1).unwrap(),
                    )),
                    _ => Err(Error::UnexpectedChar('}', pos)),
                };
            }
            Some((_, ',')) => {
                quantities.push(buf.parse::<usize>().ok());
                buf.clear();
            }
            Some((_, ch)) if ch.is_whitespace() => {}
            Some((_, ch)) if ch.is_ascii_digit() => {
                buf.push(ch);
            }
            Some((pos, ch)) => return Err(Error::UnexpectedChar(ch, pos)),
            None => return Err(Error::UnexpectedEndOfInput),
        }
    }
}

fn parse_special(chars: &mut impl Iterator<Item = (usize, char)>) -> Result<Token> {
    match chars.next() {
        None => Err(Error::UnexpectedEndOfInput),
        Some((_, 'w')) => Ok(Token::Alphanumeric),
        Some((_, 'W')) => Ok(Token::NotAlphanumeric),
        Some((_, 's')) => Ok(Token::Whitespace),
        Some((_, 'S')) => Ok(Token::NotWhitespace),
        Some((_, 'd')) => Ok(Token::Digit),
        Some((_, 'D')) => Ok(Token::NotDigit),
        Some((_, 'n')) => Ok(Token::Literal('\n')),
        Some((_, 'r')) => Ok(Token::Literal('\r')),
        Some((_, 't')) => Ok(Token::Literal('\t')),
        Some((_, '\\')) => Ok(Token::Literal('\\')),
        Some((_, '.')) => Ok(Token::Literal('.')),
        Some((_, '*')) => Ok(Token::Literal('*')),
        Some((_, '+')) => Ok(Token::Literal('+')),
        Some((_, '[')) => Ok(Token::Literal('[')),
        Some((_, ']')) => Ok(Token::Literal(']')),
        Some((_, '(')) => Ok(Token::Literal('(')),
        Some((_, ')')) => Ok(Token::Literal(')')),
        Some((_, '|')) => Ok(Token::Literal('|')),
        Some((_, '{')) => Ok(Token::Literal('{')),
        Some((_, '}')) => Ok(Token::Literal('}')),
        Some((_, 'b')) => Ok(Token::WordBoundary),
        Some((i, ch)) => Err(Error::UnexpectedChar(ch, i)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_literals() {
        let tok = parse_expr("hello".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ])
        )
    }

    #[test]
    fn test_special_digit() {
        let tok = parse_expr("\\d".chars()).expect("parsing should work");

        assert_eq!(tok, Token::Conjunction(vec![Token::Digit]))
    }

    #[test]
    fn test_any() {
        let tok = parse_expr(".".chars()).expect("parsing should work");

        assert_eq!(tok, Token::Conjunction(vec![Token::Any,]))
    }

    #[test]
    fn test_choice_simple() {
        let tok = parse_expr("[ad]".chars()).expect("parsing should work");

        let expected_disjunction = vec![Token::Literal('a'), Token::Literal('d')];

        assert!(matches!(tok, Token::Conjunction(conjunction)
            if matches!(conjunction.get(0), Some(Token::Disjunction(disjunction))
                if contains_exactly_in_any_order(disjunction, &expected_disjunction)
            )
        ));
    }

    #[test]
    fn test_choice_range() {
        let tok = parse_expr("[a-d]".chars()).expect("parsing should work");

        let expected_disjunction = vec![Token::AsciiRange('a', 'd')];

        assert!(matches!(tok, Token::Conjunction(conjunction)
            if matches!(conjunction.get(0), Some(Token::Disjunction(disjunction))
                if contains_exactly_in_any_order(disjunction, &expected_disjunction)
            )
        ));
    }

    #[test]
    fn test_choice_range_tailing_dash() {
        let tok = parse_expr("[a-d-]".chars()).expect("parsing should work");

        let expected_disjunction = vec![Token::AsciiRange('a', 'd'), Token::Literal('-')];

        assert!(matches!(tok, Token::Conjunction(conjunction)
            if matches!(conjunction.get(0), Some(Token::Disjunction(disjunction))
                if contains_exactly_in_any_order(disjunction, &expected_disjunction)
            )
        ));
    }

    #[test]
    fn test_choice_simple_tailing_dash() {
        let tok = parse_expr("[ad-]".chars()).expect("parsing should work");

        let expected_disjunction = vec![
            Token::Literal('a'),
            Token::Literal('d'),
            Token::Literal('-'),
        ];

        assert!(matches!(tok, Token::Conjunction(conjunction)
            if matches!(conjunction.get(0), Some(Token::Disjunction(disjunction))
                if contains_exactly_in_any_order(disjunction, &expected_disjunction)
            )
        ));
    }

    #[test]
    fn test_choice_multiple_ranges() {
        let tok = parse_expr("[a-d0-3-]".chars()).expect("parsing should work");

        let expected_disjunction = vec![
            Token::AsciiRange('a', 'd'),
            Token::AsciiRange('0', '3'),
            Token::Literal('-'),
        ];

        assert!(matches!(tok, Token::Conjunction(conjunction)
            if matches!(conjunction.get(0), Some(Token::Disjunction(disjunction))
                if contains_exactly_in_any_order(disjunction, &expected_disjunction)
            )
        ));
    }

    #[test]
    fn test_choice_special() {
        let tok = parse_expr("[\\]\\\\]".chars()).expect("parsing should work");

        let expected_disjunction = vec![Token::Literal(']'), Token::Literal('\\')];

        assert!(matches!(tok, Token::Conjunction(conjunction)
            if matches!(conjunction.get(0), Some(Token::Disjunction(disjunction))
                if contains_exactly_in_any_order(disjunction, &expected_disjunction)
            )
        ));
    }

    #[test]
    fn test_greedy_quantifier_star() {
        let tok = parse_expr("A*".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                0,
                None,
            )])
        )
    }

    #[test]
    fn test_greedy_quantifier_plus() {
        let tok = parse_expr("A+".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                1,
                None,
            )])
        )
    }

    #[test]
    fn test_lazy_quantifier_star() {
        let tok = parse_expr("A*?".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::LazyQuantifier(
                Box::new(Token::Literal('A')),
                0,
                None,
            )])
        )
    }

    #[test]
    fn test_lazy_quantifier_plus() {
        let tok = parse_expr("A+?".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::LazyQuantifier(
                Box::new(Token::Literal('A')),
                1,
                None,
            )])
        )
    }

    #[test]
    fn test_optional() {
        let tok = parse_expr("A?".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                0,
                Some(1),
            )])
        )
    }

    #[test]
    fn test_lazy_range_quantifier() {
        let tok = parse_expr("A{2, 4}?".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::LazyQuantifier(
                Box::new(Token::Literal('A')),
                2,
                Some(4),
            )])
        )
    }

    #[test]
    fn test_greedy_range_quantifier() {
        let tok = parse_expr("A{2, 4}".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                2,
                Some(4),
            )])
        )
    }

    #[test]
    fn test_range_quantifier_single() {
        let tok = parse_expr("A{2}".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                2,
                Some(2),
            )])
        )
    }

    #[test]
    fn test_range_quantifier_open_end() {
        let tok = parse_expr("A{2,}".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                2,
                None,
            )])
        )
    }

    #[test]
    fn test_range_quantifier_open_start() {
        let tok = parse_expr("A{,2}".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![Token::GreedyQuantifier(
                Box::new(Token::Literal('A')),
                0,
                Some(2),
            )])
        )
    }

    #[test]
    fn test_non_capturing_group() {
        let tok = parse_expr("A(?:B)C".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![
                Token::Literal('A'),
                Token::Conjunction(vec![Token::Literal('B'),]),
                Token::Literal('C'),
            ])
        )
    }

    #[test]
    fn test_capturing_group() {
        let tok = parse_expr("A(B)C".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![
                Token::Literal('A'),
                Token::Capturing(
                    Box::new(Token::Conjunction(vec![Token::Literal('B'),])),
                    None
                ),
                Token::Literal('C'),
            ])
        )
    }

    #[test]
    fn test_named_capturing_group() {
        let tok = parse_expr("A(?<test>B)C".chars()).expect("parsing should work");

        assert_eq!(
            tok,
            Token::Conjunction(vec![
                Token::Literal('A'),
                Token::Capturing(
                    Box::new(Token::Conjunction(vec![Token::Literal('B'),])),
                    Some("test".to_owned()),
                ),
                Token::Literal('C'),
            ])
        )
    }

    fn contains_exactly_in_any_order(v1: &Vec<Token>, v2: &Vec<Token>) -> bool {
        let sorted_v1: HashSet<&Token> = HashSet::from_iter(v1.into_iter());
        let sorted_v2: HashSet<&Token> = HashSet::from_iter(v2.into_iter());

        sorted_v1.len() == sorted_v2.len() && sorted_v1 == sorted_v2
    }
}
