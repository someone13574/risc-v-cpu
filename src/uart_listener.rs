use std::path::Path;

use crate::BAUD_RATE;

pub fn print_uart<P: AsRef<Path>>(port: P) {
    sudo::escalate_if_needed().unwrap();

    let mut serial_port = match serialport::new(port.as_ref().to_string_lossy(), BAUD_RATE).open() {
        Ok(serial_port) => serial_port,
        Err(e) => {
            println!(
                "Failed to open serial port {:?} with error \"{e}\"",
                port.as_ref()
            );
            return;
        }
    };

    let mut buf = [0];
    loop {
        while let Ok(n) = serial_port.read(&mut buf) {
            if n == 1 {
                println!("{}", buf[0]);
            }
        }
    }
}
