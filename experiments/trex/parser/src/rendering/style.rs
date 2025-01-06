#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Color {
    #[default]
    Reset,
    Black,
    Red,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    LightBlack,
    LightRed,
    LightGreen,
    LightYellow,
    LightBlue,
    LightMagenta,
    LightCyan,
    LightWhite,
}

pub struct ColorIterator {
    idx: usize,
    values: Vec<Color>,
}

impl ColorIterator {
    fn new(values: Vec<Color>) -> Self {
        if values.len() < 1 {
            panic!("bad code");
        }

        Self { idx: 0, values }
    }
}

impl ColorIterator {
    pub fn next_color(&mut self) -> Color {
        self.next().unwrap()
    }
}

impl Iterator for ColorIterator {
    type Item = Color;

    fn next(&mut self) -> Option<Self::Item> {
        self.idx += 1;

        if self.idx == self.values.len() {
            self.idx = 0;
        }

        self.values.get(self.idx).copied()
    }
}

impl Color {
    pub fn background_iter() -> ColorIterator {
        ColorIterator::new(vec![
            Color::Black,
            Color::Red,
            Color::Yellow,
            Color::Blue,
            Color::Magenta,
            Color::Cyan,
            Color::White,
        ])
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Format {
    #[default]
    Reset,
    Bold,
    Dim,
    Underline,
    Reverse,
    Italic,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Style {
    pub background: Option<Color>,
    pub foreground: Option<Color>,
    pub format: Option<Format>,
}

impl Style {
    pub fn apply(&mut self, s: &Style) {
        if let Some(color) = s.background {
            self.background = Some(color);
        }
        if let Some(color) = s.foreground {
            self.foreground = Some(color);
        }
        if let Some(format) = s.format {
            self.format = Some(format);
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Styles {
    width: usize,
    height: usize,
    s: Vec<Style>,
}

impl Styles {
    pub fn set(&mut self, row: usize, col: usize, styles: &Styles) {
        for r in 0..styles.height {
            let offset = (row + r) * self.width + col;

            for c in 0..styles.width {
                self.s
                    .get_mut(c + offset)
                    .expect("style at offset")
                    .apply(styles.get(r, c).unwrap());
            }
        }
    }

    pub fn get(&self, row: usize, col: usize) -> Option<&Style> {
        let offset = row * self.width + col;
        self.s.get(offset)
    }

    pub fn new(width: usize, height: usize) -> Self {
        Self {
            width,
            height,
            s: (0..width * height).map(|_| Style::default()).collect(),
        }
    }

    pub fn clear(&mut self, s: Style) {
        self.s.splice(.., (0..self.s.len()).map(|_| s));
    }
}
