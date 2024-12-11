use std::{
    env,
    fs::File,
    io::Read,
    path::{Path, PathBuf},
    process::{exit, ExitCode},
    time::Duration,
};

use anyhow::{anyhow, bail, Context, Result};
use clap::{Parser, Subcommand};
use scryer_prolog::{Machine, MachineConfig};
use tokio::task::JoinHandle;

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Repl { extensions: Vec<String> },
    Parse { file_path: PathBuf },
}

fn main() {
    if let Some(dir) = env::var("BUILD_WORKING_DIRECTORY").ok() {
        env::set_current_dir(dir)
            .expect("Could not set the current dir to the value of BUILD_WORKING_DIRECTORY");
    }

    match Cli::parse().command {
        Commands::Repl { extensions } => repl(extensions).unwrap(),
        Commands::Parse { file_path } => parse(file_path).unwrap(),
    };
}

fn repl(extensions: Vec<String>) -> Result<()> {
    let mut wam = Machine::new(MachineConfig::default());
    let mut extension_buf = String::new();

    for extension in extensions {
        eprintln!("Loading extension file {extension}");
        let mut file = File::open(extension)?;
        file.read_to_string(&mut extension_buf)?;
        extension_buf += "\n";
    }

    wam.load_module_string("lisprolog", include_str!("lisprolog.pl").to_string());
    wam.load_module_string("lisp", include_str!("lisp.pl").to_string());
    wam.consult_module_string("extensions", extension_buf);

    wam.run_query("use_module(library('$toplevel')), repl.".to_string())
        .map_err(|s| anyhow!(s))?;

    Ok(())
}

fn parse(file_path: impl AsRef<Path>) -> Result<()> {
    let mut wam = Machine::new(MachineConfig::default());

    wam.load_module_string("lisprolog", include_str!("lisprolog.pl").to_string());
    wam.load_module_string("lisp", include_str!("lisp.pl").to_string());

    let query = format!(
        "use_module(library(pio)), use_module(library(lisp)), phrase_from_file(sexprs(A), {file_path:?}).",
        file_path = file_path.as_ref(),
    );

    match wam.run_query(query) {
        Ok(res) => dbg!(res),
        Err(msg) => return bail!(msg),
    };

    Ok(())
}
