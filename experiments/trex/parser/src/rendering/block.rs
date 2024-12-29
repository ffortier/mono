use std::fmt::Display;

use super::{style::Styles, Styled};

#[derive(Debug, Clone, PartialEq)]
pub struct Block {
    height: usize,
    width: usize,
    s: String,
    styles: Styles,
}

impl Block {
    pub fn new(width: usize, height: usize) -> Self {
        Self {
            width,
            height,
            s: (" ".repeat(width) + "\n").repeat(height),
            styles: Styles::new(width, height),
        }
    }

    pub fn with_styles<F>(&mut self, func: F)
    where
        F: FnOnce(&mut Styles),
    {
        (func)(&mut self.styles);
    }

    pub fn set<T: Styled + ?Sized>(&mut self, row: usize, col: usize, s: &T) {
        let mut row = row;

        if let Some(styles) = s.style() {
            self.styles.set(row, col, styles);
        }

        for ln in s.as_str().lines() {
            let offset = row * (self.width + 1) + col;
            let len = ln.chars().count();

            let start = self
                .s
                .char_indices()
                .nth(offset)
                .expect("char at offset start")
                .0;

            let end = self
                .s
                .char_indices()
                .nth(offset + len)
                .expect("char at offset end")
                .0;

            self.s.replace_range(start..end, ln);
            row += 1
        }
    }

    pub fn width(&self) -> usize {
        self.width
    }

    pub fn height(&self) -> usize {
        self.height
    }
}

fn resize((width, height): (usize, usize), ln: &str) -> (usize, usize) {
    (width.max(ln.chars().count()), height + 1)
}

impl Display for Block {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.s)
    }
}

impl From<&str> for Block {
    fn from(value: &str) -> Self {
        let (width, height) = value.lines().fold((0, 0), resize);
        let mut buf = Self::new(width, height);

        buf.set(0, 0, value);
        buf
    }
}

impl AsRef<str> for Block {
    fn as_ref(&self) -> &str {
        &self.s
    }
}

impl Styled for Block {
    fn as_str(&self) -> &str {
        self.as_ref()
    }

    fn style(&self) -> Option<&Styles> {
        Some(&self.styles)
    }
}
