use std::path::Path;

use crate::BAUD_RATE;

pub fn upload_program<P: AsRef<Path>>(program: P, port: P) {
    sudo::escalate_if_needed().unwrap();

    let hex_file = std::fs::read_to_string(program).unwrap().replace('\n', "");
    let file_bytes = hex::decode(hex_file).unwrap();
    let upload_bytes = (file_bytes.len() as u16)
        .to_be_bytes()
        .into_iter()
        .chain(
            file_bytes
                .chunks(4)
                .flat_map(|word| word.iter().rev())
                .copied(),
        )
        .collect::<Vec<_>>();

    let display_bytes = upload_bytes
        .iter()
        .map(|&byte| hex::encode([byte]))
        .collect::<Vec<_>>()
        .join(" ");
    println!(
        "Uploading {} bytes (2 len, {} data): {}\n",
        upload_bytes.len(),
        upload_bytes.len() as i32 - 2,
        display_bytes
    );

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
    match serial_port.write_all(&upload_bytes) {
        Ok(_) => println!(
            "Successfully wrote {} bytes to port {:?}",
            upload_bytes.len(),
            port.as_ref()
        ),
        Err(e) => println!(
            "Failed to write to serial port {:?} with error \"{e}\"",
            port.as_ref()
        ),
    }
}
