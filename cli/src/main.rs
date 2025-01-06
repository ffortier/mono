use clap::{Parser, Subcommand};

#[derive(Debug, Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Hello,
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Hello => println!("Hello World!"),
    }
}
