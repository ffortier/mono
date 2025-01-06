use std::{
    fmt::{Arguments, Display},
    str::FromStr,
};

use parser::Token;
pub use rendering::style::{Color, Format};

use crate::rendering::Styled;

mod compiler;
pub mod error;
mod parser;
mod rendering;

pub struct Regex {
    tok: Token,
}

#[derive(Debug, PartialEq, Eq, Clone, Copy, Default)]
pub struct Style {
    pub background: Color,
    pub foreground: Color,
    pub format: Format,
}

impl From<rendering::style::Style> for Style {
    fn from(value: rendering::style::Style) -> Self {
        Self {
            background: value.background.unwrap_or_default(),
            foreground: value.foreground.unwrap_or_default(),
            format: value.format.unwrap_or_default(),
        }
    }
}

struct StyledOutput<'a, F>
where
    F: Fn(&Style, &Arguments<'_>) -> String + 'a,
{
    tok: &'a Token,
    style_func: F,
}

impl<'a, F> Display for StyledOutput<'a, F>
where
    F: Fn(&Style, &Arguments<'_>) -> String + 'a,
{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let block = rendering::render_token(&self.tok);
        let mut dummy = Color::background_iter();

        for ln in block.as_str().lines() {
            write!(
                f,
                "{}",
                (self.style_func)(
                    &Style {
                        background: dummy.next_color(),
                        foreground: dummy.next_color(),
                        ..Default::default()
                    },
                    &format_args!("{ln}"),
                )
            )?;
            writeln!(
                f,
                "{}",
                (self.style_func)(&Style::default(), &format_args!(""))
            )?;
        }

        Ok(())
    }
}

impl Regex {
    pub fn with_style<'a, F>(&'a self, style_func: F) -> Box<dyn Display + 'a>
    where
        F: Fn(&Style, &Arguments<'_>) -> String + 'a,
    {
        Box::new(StyledOutput {
            tok: &self.tok,
            style_func,
        })
    }
}

impl Display for Regex {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        writeln!(f, "{}", rendering::render_token(&self.tok))
    }
}

impl FromStr for Regex {
    type Err = error::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let tok = parser::parse_expr(s.chars())?;

        Ok(Self { tok })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_phone_number_display() {
        let re: Regex = r#"^(\+\d{1,2}\s)?\(?\d{3}\)?[a-z\s.-]\d{3}[\s.-]\d{4}$"#
            .parse()
            .expect("parse");

        _ = format!("{re}");
    }

    #[test]
    fn test_hello_display() {
        let re: Regex = r#"hello (?:\W+|[0-9])+"#.parse().expect("parse");

        _ = format!("{re}");
    }
}
