use std::io;

#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("Error reading file")]
    IO(#[from] io::Error),
    #[error("d64 format must have a siuze of 174848 bytes (683 sectors), got {0}")]
    UnexpectedSize(usize),
    #[error("Invalid track number {0}.")]
    InvalidTrackNumber(u8),
    #[error("Invalid sector number {0}/{0}.")]
    InvalidSectorNumber(u8, u8),
}
