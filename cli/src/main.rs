use std::io::{Read, Write};

use anyhow::{anyhow, Context, Result};
use clap::{Parser, Subcommand};
use reqwest::{blocking::Client, Url};
use sha2::{Digest, Sha256};

#[derive(Debug, Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Hello,
    Fetch { urls: Vec<String> },
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Hello => println!("Hello World!"),
        Commands::Fetch { urls } => fetch(&urls).unwrap(),
    }
}

fn fetch(urls: &Vec<String>) -> Result<()> {
    let client = Client::new();

    let url: Url = urls
        .get(0)
        .ok_or_else(|| anyhow!("Expected at leat one url"))?
        .parse()
        .context("Failed to parse url")?;

    let mut response = client
        .get(url.clone())
        .send()
        .context("Failed to fetch url")?;

    let mut digest = Sha256::new();
    let mut buf = [0u8; 1024];

    loop {
        let len = response.read(&mut buf)?;
        if len == 0 {
            break;
        }
        digest.update(&buf[0..len]);
    }

    let hash = digest.finalize();
    let hash: String = hex::encode(hash);

    println!(
        r#"http_archive = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")"#
    );

    println!(
        r#"http_archive(name={name:?}, urls={urls:?}, sha256={hash:?})"#,
        name = url.path_segments().unwrap().last().unwrap_or_default()
    );

    Ok(())
}
