use petscii::PetsciiString;
use std::{
    fmt,
    fs::File,
    io::{self, Read},
};

pub mod error;

pub struct D64Image {
    bytes: Vec<u8>,
}

const SECTOR_SIZE: usize = 256;
const OFFSET_1: usize = 0;
const OFFSET_18: usize = OFFSET_1 + (SECTOR_SIZE * 21 * (17 - 1 + 1));
const OFFSET_25: usize = OFFSET_18 + (SECTOR_SIZE * 21 * (24 - 18 + 1));
const OFFSET_31: usize = OFFSET_25 + (SECTOR_SIZE * 21 * (30 - 25 + 1));

impl D64Image {
    pub fn read_from_file(mut file: File) -> Result<Self, error::Error> {
        let mut bytes = vec![];

        file.read_to_end(&mut bytes)?;

        if bytes.len() != 174848 {
            return Err(error::Error::UnexpectedSize(bytes.len()));
        }

        Ok(Self { bytes })
    }

    fn get_track_offset(&self, num: u8) -> Result<(usize, usize), error::Error> {
        let num = num as usize;

        let (offset, sector_count) = match num {
            1..=17 => (SECTOR_SIZE * 21 * (num - 1) + OFFSET_1, 21),
            18..=24 => (SECTOR_SIZE * 19 * (num - 18) + OFFSET_18, 19),
            25..=30 => (SECTOR_SIZE * 18 * (num - 25) + OFFSET_25, 18),
            31..=35 => (SECTOR_SIZE * 17 * (num - 31) + OFFSET_31, 17),
            _ => return Err(error::Error::InvalidTrackNumber(num as u8)),
        };

        Ok((offset, sector_count))
    }

    fn get_sector_offset(&self, track: u8, sector: u8) -> Result<usize, error::Error> {
        let (track_offset, sector_count) = self.get_track_offset(track)?;

        if (sector as usize) >= sector_count {
            return Err(error::Error::InvalidSectorNumber(track, sector));
        }

        Ok(track_offset + (sector as usize) * SECTOR_SIZE)
    }

    pub fn get_track_sector(&self, track: u8, sector: u8) -> Result<&[u8], error::Error> {
        let offset = self.get_sector_offset(track, sector)?;

        Ok(&self.bytes[offset..offset + SECTOR_SIZE])
    }

    pub fn get_track_sector_mut(
        &mut self,
        track: u8,
        sector: u8,
    ) -> Result<&mut [u8], error::Error> {
        let offset = self.get_sector_offset(track, sector)?;

        Ok(&mut self.bytes[offset..offset + SECTOR_SIZE])
    }
}

pub struct BlockAvailabilityMap {
    pub track_of_first_directory: u8,
    pub sector_of_first_directory: u8,
    pub version: u8,
    pub reserved: u8,
    // pub available_blocks: &'a [u8],
    pub disk_name: PetsciiString,
    pub disk_id: u16,
}

impl BlockAvailabilityMap {
    pub fn try_read_from(sector: &[u8]) -> Result<Self, error::Error> {
        Ok(BlockAvailabilityMap {
            track_of_first_directory: sector[0],
            sector_of_first_directory: sector[1],
            version: sector[2],
            reserved: sector[3],

            // available_blocks: &sector[4..=143],
            disk_name: PetsciiString::from(&sector[144..=161]),
            disk_id: (((sector[163] as u16) << 8) | (sector[162] as u16)),
        })
    }

    pub fn try_write_to(&self, _sector: &mut [u8]) -> Result<(), error::Error> {
        todo!()
    }
}

impl fmt::Debug for BlockAvailabilityMap {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        #[derive(Debug)]
        struct BlockAvailabilityMap {
            track_of_first_directory: u8,
            sector_of_first_directory: u8,
            version: u8,
            reserved: u8,
            // available_blocks: Vec<u8>,
            disk_name: String,
            disk_id: u16,
        };

        fmt::Debug::fmt(
            &BlockAvailabilityMap {
                track_of_first_directory: self.track_of_first_directory,
                sector_of_first_directory: self.sector_of_first_directory,
                version: self.version,
                reserved: self.reserved,
                // available_blocks: self.available_blocks.to_vec(),
                disk_name: self.disk_name.to_string(),
                disk_id: self.disk_id,
            },
            f,
        )
    }
}
