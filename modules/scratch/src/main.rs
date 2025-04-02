pub mod ast;
pub mod parser;

use std::path::PathBuf;

use clap::{Parser, Subcommand};

#[derive(Debug, Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Compile {
        #[arg(long, short)]
        out_file: PathBuf,

        #[arg(long, short)]
        target: Option<String>,

        #[arg(help = "If specified, use custom directory structure <short_path:path>...")]
        sources: Vec<PathBuf>,
    },
}

pub fn main() {
    let cli = Cli::parse();

    dbg!(&cli);

    println!("Hello Scratchy!");

    match &cli.command {
        Commands::Compile {
            out_file,
            target,
            sources,
        } => std::fs::write(out_file, "hello").unwrap(),
    }
}
