mod create_mem_init;
mod generate_microcode;
mod microcode;
mod uart_listener;
mod upload_program;

pub const BAUD_RATE: u32 = 9600;

use std::path::PathBuf;

use clap::{Args, Parser, Subcommand};
use create_mem_init::create_mem_init;
use uart_listener::print_uart;
use upload_program::upload_program;

use crate::generate_microcode::generate_microcode;

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Generate the microcode rom data
    GenerateMicrocode(GenerateMicrocode),
    /// Create memory initialization file from a hex file
    CreateMemInit(CreateMemInit),
    /// Upload to program over uart
    UploadProgram(UploadProgram),
}

#[derive(Args)]
struct GenerateMicrocode {
    /// Overwrite `microcode.mem` in the system verilog design
    #[arg(short, long, default_value_t = false)]
    write: bool,
}

#[derive(Args)]
struct CreateMemInit {
    hex_file: PathBuf,
    dst: PathBuf,
}

#[derive(Args)]
struct UploadProgram {
    hex_file: PathBuf,
    port: Option<PathBuf>,
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::GenerateMicrocode(args) => {
            let microcode = generate_microcode();
            println!("{microcode}");

            if args.write {
                std::fs::write("design/microcode.mem", microcode)
                    .expect("failed to write microcode to design file");
            }
        }
        Commands::CreateMemInit(args) => {
            create_mem_init(&args.hex_file, &args.dst);
        }
        Commands::UploadProgram(args) => {
            if let Some(port) = &args.port {
                upload_program(&args.hex_file, port);
                print_uart(port);
            } else {
                let ports = serialport::available_ports().unwrap();
                for port in ports {
                    println!("{:?}", port);
                }
            }
        }
    }
}
