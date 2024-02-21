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
    /// Write a binary executable to the fpga using an arduino
    FlashExecutable(FlashExecutable),
    /// Generate the microcode rom data
    GenerateMicrocode(GenerateMicrocode),
}

#[derive(Args)]
struct FlashExecutable {
    path: PathBuf,
}

#[derive(Args)]
struct GenerateMicrocode {
    /// Overwrite `microcode.mem` in the system verilog design
    #[arg(short, long, default_value_t = false)]
    write: bool,
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::FlashExecutable(_args) => {}
        Commands::GenerateMicrocode(args) => {
            let microcode = generate_microcode();
            println!("{microcode}");

            if args.write {
                std::fs::write("design/microcode.mem", microcode)
                    .expect("failed to write microcode to design file");
            }
        }
    }
}
