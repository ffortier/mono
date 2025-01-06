#[derive(thiserror::Error, Debug)]
#[non_exhaustive]
pub enum Error {
    #[error("Unexpected end of input")]
    UnexpectedEndOfInput,
    #[error("Unexpected end of input")]
    UnexpectedChar(char, usize),
}

pub type Result<T> = std::result::Result<T, Error>;
