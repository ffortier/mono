use crate::parser::Token;

pub struct Automaton<'a> {
    states: Vec<State<'a>>,
    start_state: Option<&'a State<'a>>,
}

impl<'a> Automaton<'a> {
    pub fn new() -> Self {
        Self {
            start_state: None,
            states: vec![],
        }
    }
}

enum Input {
    Char(char),
    Start,
    End,
}

struct State<'a> {
    transitions: Vec<Box<dyn Fn(&Input) -> Option<&'a State<'a>> + 'a>>,
}

impl<'a> State<'a> {
    pub fn next(&'a self, input: &Input) -> Option<&'a State> {
        todo!()
    }
}

#[cfg(test)]
mod tests {
    use super::Automaton;

    #[test]
    fn test() {
        // let automaton = Automaton::new();
        // automaton.start_state.unwrap().next(&Input::Start).unwrap()
    }
}
