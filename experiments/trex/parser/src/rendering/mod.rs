use block::Block;
pub mod block;
pub mod style;

use std::cmp::Ordering;

use crate::parser::Token;

use self::style::{Color, Format, Style, Styles};

pub trait Styled {
    fn as_str(&self) -> &str;
    fn style(&self) -> Option<&Styles>;
}

impl Styled for str {
    fn as_str(&self) -> &str {
        self
    }

    fn style(&self) -> Option<&Styles> {
        None
    }
}

fn render_conjunction(children: &Vec<Token>) -> Block {
    let child_blocks: Vec<_> = children.into_iter().map(render_token).collect();
    let (width, height) = child_blocks
        .iter()
        .fold((0, 0), |(w, h), b| (w + b.width(), h.max(b.height())));

    let mut new_block = Block::new(width, height);
    let mut col = 0;

    for child_block in child_blocks.iter() {
        let row = (height - child_block.height()) / 2;
        new_block.set(row, col, child_block);
        col += child_block.width();
    }

    new_block
}

fn render_disjunction_line(idx: usize, len: usize, ordering: Ordering, width: usize) -> String {
    match ordering {
        Ordering::Equal if idx == 0 => format!("┬{}┬", "─".repeat(width)),
        Ordering::Equal if idx == len - 1 => format!("┴{}┴", "─".repeat(width)),
        Ordering::Equal => format!("┼{}┼", "─".repeat(width)),
        Ordering::Less if idx == 0 => format!("╭{}╮", "─".repeat(width)),
        Ordering::Greater if idx == len - 1 => format!("╰{}╯", "─".repeat(width)),
        _ => format!("├{}┤", "─".repeat(width)),
    }
}

fn render_disjunction(children: &Vec<Token>) -> Block {
    if children.len() == 1 {
        return render_token(children.iter().next().unwrap());
    }

    let child_blocks: Vec<_> = children.into_iter().map(render_token).collect();
    let (width, height) = child_blocks
        .iter()
        .fold((0, 0), |(w, h), b| (w.max(b.width()), h + b.height()));

    let height = (height + 1) % 2 + height;
    let middle = height / 2;

    let mut new_block = Block::new(width + 2, height);
    let mut row = 0;

    if child_blocks.len() >= 2 {
        let last = child_blocks.last().unwrap();
        let first_middle = child_blocks.get(0).unwrap().height() / 2;
        let last_middle = last.height() / 2
            + child_blocks.iter().fold(0, |sum, b| sum + b.height())
            - last.height() / 2
            - 1;

        for r in first_middle..last_middle {
            new_block.set(r, 0, format!("│{}│", " ".repeat(width)).as_str());
        }
    }

    new_block.set(middle, 0, format!("┤{}├", " ".repeat(width)).as_str());

    for (i, child_block) in child_blocks.iter().enumerate() {
        let child_middle = child_block.height() / 2;

        new_block.set(
            row + child_middle,
            0,
            render_disjunction_line(
                i,
                child_blocks.len(),
                (row + child_middle).cmp(&middle),
                width,
            )
            .as_str(),
        );

        new_block.set(row, 1, child_block);
        row += child_block.height();
    }

    new_block
}

fn render_quantifier(tok: &Token, min: usize, max: Option<usize>) -> Block {
    let label = match max {
        Some(1) if min == 0 => "".to_owned(),
        Some(max) if max == min => format!("={min}"),
        Some(max) if min == 0 => format!("..={max}"),
        Some(max) => format!("{min}..={max}"),
        None if min == 0 => format!(".."),
        None => format!("{min}.."),
    };

    let block = render_token(tok);
    let min_width = label.chars().count().max(2);
    let zero = min == 0;
    let more_than_one = max.unwrap_or(2) > 1;
    let width = block.width().max(min_width);
    let mut new_block = Block::new(width + 2, block.height() + 4);

    if zero {
        for i in 2..new_block.height() / 2 {
            new_block.set(i, 0, format!("│{}│", " ".repeat(width)).as_str());
        }

        new_block.set(1, 0, format!("╭{}╮", "─".repeat(width)).as_str());
        new_block.set(
            new_block.height() / 2,
            0,
            format!("┴{}┴", "─".repeat(width)).as_str(),
        );
    } else {
        new_block.set(
            new_block.height() / 2,
            0,
            format!("─{}─", "─".repeat(width)).as_str(),
        );
    }

    if more_than_one {
        new_block.set(
            block.height() + 2,
            1,
            format!("╰{}╯", "─".repeat(width - 2)).as_str(),
        );
        new_block.set(block.height() + 3, 1, label.as_str());
    }

    new_block.set(2, 1, &block);
    new_block
}

fn render_special(s: &str) -> Block {
    let mut b = Block::from(s);

    b.with_styles(|styles| {
        styles.clear(Style {
            foreground: Some(Color::Blue),
            format: Some(Format::Bold),
            ..Default::default()
        })
    });

    b
}

pub fn render_token(tok: &Token) -> Block {
    match tok {
        Token::Literal(ch) => Block::from(format!("{ch}").as_str()),
        Token::Start => render_special("^"),
        Token::End => render_special("$"),
        Token::Alphanumeric => render_special("\\w"),
        Token::NotAlphanumeric => render_special("\\W"),
        Token::Digit => render_special("\\d"),
        Token::NotDigit => render_special("\\D"),
        Token::Whitespace => render_special("\\s"),
        Token::NotWhitespace => render_special("\\S"),
        Token::WordBoundary => render_special("\\b"),
        Token::Any => render_special("."),
        Token::Conjunction(tokens) => render_conjunction(tokens),
        Token::Disjunction(tokens) => render_disjunction(tokens),
        Token::LazyQuantifier(tok, min, max) => render_quantifier(tok, *min, *max),
        Token::GreedyQuantifier(tok, min, max) => render_quantifier(tok, *min, *max),
        Token::Capturing(tok, _) => render_token(tok),
        Token::AsciiRange(start, end) => Block::from(format!("{start}-{end}").as_str()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_block_size() {
        let b1: Block = "My\nfirst\nblock".into();

        assert_eq!(b1.width(), 5);
        assert_eq!(b1.height(), 3);
    }

    #[test]
    fn test_set_block_in_block() {
        let b1: Block = "My\nfirst\nblock".into();
        let mut b2 = Block::new(10, 5);

        b2.set(2, 1, &b1);

        assert_eq!(
            b2.as_ref(),
            vec![
                "          ",
                "          ",
                " My       ",
                " first    ",
                " block    ",
                "",
            ]
            .join("\n")
        );
    }

    #[test]
    fn test_literal() {
        let b = render_token(&Token::Literal('a'));

        assert_eq!(b.width(), 1);
        assert_eq!(b.height(), 1);
        assert_eq!(b.as_str(), "a\n");
    }

    #[test]
    fn test_conjunction() {
        let b = render_token(&Token::Conjunction(vec![
            Token::Literal('h'),
            Token::Literal('e'),
            Token::Literal('l'),
            Token::Literal('l'),
            Token::Literal('o'),
        ]));

        assert_eq!(b.width(), 5);
        assert_eq!(b.height(), 1);
        assert_eq!(b.as_str(), "hello\n");
    }

    #[test]
    fn test_disjunction_odd() {
        let b = render_token(&Token::Disjunction(vec![
            Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ]),
            Token::Conjunction(vec![Token::Literal('a')]),
            Token::Whitespace,
        ]));

        assert_eq!(
            b.as_str(),
            &vec![
                "╭hello╮", //
                "┼a────┼",
                "╰\\s───╯",
                "",
            ]
            .join("\n")
        );
    }

    #[test]
    fn test_disjunction_even() {
        let b = render_token(&Token::Disjunction(vec![
            Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ]),
            Token::Conjunction(vec![Token::Literal('a')]),
        ]));

        assert_eq!(
            b.as_str(),
            &vec![
                "╭hello╮", //
                "┴a────┴",
                "       ",
                "",
            ]
            .join("\n")
        );
    }

    #[test]
    fn test_quantifier_0_n() {
        let b = render_token(&Token::LazyQuantifier(
            Box::new(Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ])),
            0,
            None,
        ));

        assert_eq!(
            b.as_str(),
            &vec![
                "       ",
                "╭─────╮", //
                "┴hello┴",
                " ╰───╯ ",
                " ..    ",
                "",
            ]
            .join("\n")
        );
    }

    #[test]
    fn test_quantifier_0_2() {
        let b = render_token(&Token::LazyQuantifier(
            Box::new(Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ])),
            0,
            Some(2),
        ));

        assert_eq!(
            b.as_str(),
            &vec![
                "       ",
                "╭─────╮", //
                "┴hello┴",
                " ╰───╯ ",
                " ..=2  ",
                "",
            ]
            .join("\n")
        );
    }

    #[test]
    fn test_quantifier_1_n() {
        let b = render_token(&Token::LazyQuantifier(
            Box::new(Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ])),
            1,
            None,
        ));

        assert_eq!(
            b.as_str(),
            &vec![
                "       ", //
                "       ",
                "─hello─",
                " ╰───╯ ",
                " 1..   ",
                "",
            ]
            .join("\n")
        );
    }

    #[test]
    fn test_quantifier_0_1() {
        let b = render_token(&Token::LazyQuantifier(
            Box::new(Token::Conjunction(vec![
                Token::Literal('h'),
                Token::Literal('e'),
                Token::Literal('l'),
                Token::Literal('l'),
                Token::Literal('o'),
            ])),
            0,
            Some(1),
        ));

        assert_eq!(
            b.as_str(),
            &vec![
                "       ",
                "╭─────╮", //
                "┴hello┴",
                "       ",
                "       ",
                "",
            ]
            .join("\n")
        );
    }
}
