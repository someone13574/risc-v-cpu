mod generate_microcode;

use std::path::PathBuf;

use clap::{Args, Parser, Subcommand};

use crate::generate_microcode::generate_microcode;

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    FlashExecutable(FlashExecutable),
    GenerateMicrocode,
}

#[derive(Args)]
struct FlashExecutable {
    path: PathBuf,
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::FlashExecutable(_args) => {}
        Commands::GenerateMicrocode => {
            println!("{}", generate_microcode());
        }
    }
}
