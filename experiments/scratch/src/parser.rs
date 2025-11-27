#[derive(Debug)]
pub struct Program {
    statements: Vec<Statement>,
}

#[derive(Debug)]
pub enum SignatureToken {
    Word(String),
    Expr,
}

#[derive(Debug)]
pub enum ConcreteSignatureToken {
    Word(String),
    Expr(Expr),
}

#[derive(Debug)]
pub struct Signature {
    tokens: Vec<SignatureToken>,
}

#[derive(Debug)]
pub struct Statement {
    signature: Signature,
    args: Vec<Expr>,
    body: Vec<Statement>,
}

#[derive(Debug)]
pub enum Expr {
    String(String),
    Number(f64),
    Func(Statement),
}

peg::parser! {

    pub grammar scratch_parser() for str {
        pub rule program() -> Program
            = statements:(statement() ** _) { Program { statements } }

        rule statement() -> Statement
            = "(" tokens:(concrete_signature_token() ** _) body:(_ body:(statement() ** _) { body })? ")" {
                let mut args = vec![];
                let mut signature_tokens = vec![];

                for token in tokens.into_iter() {
                    match token {
                        ConcreteSignatureToken::Word(w) => {
                            signature_tokens.push(SignatureToken::Word(w));
                        }
                        ConcreteSignatureToken::Expr(e) => {
                            signature_tokens.push(SignatureToken::Expr);
                            args.push(e);
                        }
                    }
                }

                Statement { signature: Signature { tokens: signature_tokens }, args, body: body.unwrap_or_default() }
             }

        rule concrete_signature_token() -> ConcreteSignatureToken
            = "[" e:expr() "]" { ConcreteSignatureToken::Expr(e) }
            / w:word() { ConcreteSignatureToken::Word(w) }

        rule word() -> String
            = w:$(['a'..'z' | 'A'..'Z' | '0'..'9' | '_' | '-' | '+' | '*' | '/']+) { w.to_string() }

        rule expr() -> Expr
            = number_expr()
            / string_expr()
            / func_expr()
            // / arithmetic_expr()

        rule number_expr() -> Expr
            = n:$("-"? ['0'..'9']+ ("." ['0'..'9']+)?) { Expr::Number(n.parse().expect("Failed to parse number")) }

        rule string_expr() -> Expr
            = "\"" s:$([^'"'|'\n']*) "\"" { Expr::String(s.to_string()) }

        rule func_expr() -> Expr
            = s:statement() { Expr::Func(s) }

        rule _ = quiet!{ [' ' | '\n' | '\t']+ }

    }

}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parser() {
        let program = scratch_parser::program(
            r#"(+ [1] [2] (say ["hello world"] for [(+ 1 2)] seconds)) ( ) ()"#,
        )
        .expect("Failed to parse");

        assert_eq!(program.statements.len(), 3);
    }
}
