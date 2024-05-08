mod create_mem_init;
mod generate_microcode;
mod microcode;
mod upload_program;

use crate::generate_microcode::generate_microcode;
use clap::{Args, Parser, Subcommand};
use create_mem_init::create_mem_init;
use std::path::PathBuf;
use upload_program::upload_program;

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
    /// Upload a program to the processor via an arduino
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
    serial_port: Option<PathBuf>,
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
            if let Some(serial_port) = &args.serial_port {
                upload_program(&args.hex_file, serial_port);
            } else {
                let ports = serialport::available_ports()
                    .unwrap()
                    .into_iter()
                    .filter(|port| port.port_type != serialport::SerialPortType::Unknown)
                    .collect::<Vec<_>>();

                if ports.is_empty() {
                    println!("No devices found.");
                    return;
                }

                println!("Available devices:");

                for serial_port in ports {
                    if let serialport::SerialPortType::UsbPort(usb_port) = serial_port.port_type {
                        println!(
                            "  \"{}\": \"{}\" ({})",
                            serial_port.port_name,
                            usb_port.product.unwrap_or("unknown product".to_string()),
                            usb_port
                                .manufacturer
                                .unwrap_or("unknown manufacturer".to_string())
                        );
                    }
                }
            }
        }
    }
}
