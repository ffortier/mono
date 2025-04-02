use crate::ast::*;

peg::parser! {
    pub grammar scratch_parser() for str {
        pub rule program() -> Program
            = blocks:(block() ** _) { Program { blocks } }

        // Blocks
        pub rule block() -> Block
            = b:do_block() { b.into() }

        rule do_block() -> Do = begin:position!() "(" _? "do" _ instructions:(instruction() ** _) _? ")" end:position!() {
            Do {
                span: Span::new(begin, end),
                instructions: instructions,
            }
        }

        // Instructions
        pub rule instruction() -> Instruction
            = i:if_instruction() { i.into() }
            / i:invocation() { i.into() }


        rule if_instruction() -> If = begin:position!() "(" _? "if" _ "true" _ then_block:do_block() else_block:(_ d:do_block() {d} )? _? ")" end:position!() {
            If {
                span: Span::new(begin, end),
                condition: Expression::Literal(Literal { span: Span::new(begin, end), value: "true".to_string() }),
                then_block,
                else_block,
            }
        }

        rule invocation() -> Invocation = "()" {
            todo!()
        }

        // Common
        rule _ = quiet! { [' ' | '\r' | '\n' | '\t']+ }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_empty_program() {
        let input = "";
        let output = scratch_parser::program(input).expect("Could not parse program");

        assert_eq!(output, Program { blocks: vec![] });
    }

    #[test]
    fn test_top_level_do() {
        let input = "(do )";
        let output = scratch_parser::program(input).expect("Could not parse program");

        assert!(matches!(output, Program { blocks } if blocks.len() == 1));
    }

    #[test]
    fn test_if() {
        let input = "(do (if true (do )))";
        let output = scratch_parser::program(input).expect("Could not parse program");

        match &output.blocks[0] {
            Block::Do(d) if d.instructions.len() == 1 => match &d.instructions[0] {
                Instruction::If(i) => {
                    assert!(i.else_block.is_none())
                }
                _ => assert!(false),
            },
            _ => assert!(false),
        }
    }
}
