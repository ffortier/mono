use std::fs::File;

use anyhow::Context;
use clap::Parser;
use disquette::{BlockAvailabilityMap, D64Image};

#[derive(Parser)]
struct Args {
    file_name: String,
}

fn main() -> anyhow::Result<()> {
    let args = Args::parse();
    let file = File::open(&args.file_name)
        .with_context(|| format!("Failed to open {}", &args.file_name))?;

    let d64 = D64Image::read_from_file(file).context("Failed to read disk image")?;
    let bam = BlockAvailabilityMap::try_read_from(d64.get_track_sector(18, 0)?)
        .context("Failed to get BAM")?;

    println!("{:#?}", &bam);

    Ok(())
}
