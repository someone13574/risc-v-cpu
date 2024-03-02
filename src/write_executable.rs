use std::path::Path;

pub fn write_executable(path: &Path, port: Option<String>) {
    let ports = serialport::available_ports().unwrap();

    if let Some(port) = port {
        if !ports
            .iter()
            .map(|port| port.port_name.clone())
            .collect::<Vec<_>>()
            .contains(&port)
        {
            println!("Port `{port}` not found");
            return;
        }

        let _bytes_to_write = std::fs::read_to_string(path)
            .unwrap()
            .lines()
            .enumerate()
            .flat_map(|(word_idx, line)| {
                let hex = hex::decode(line.trim()).unwrap();
                hex.iter()
                    .enumerate()
                    .map(|(byte_idx, &byte)| (byte, word_idx, byte_idx))
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        unimplemented!();
    } else {
        println!("No port supplied. Available ports:");
        for port in ports {
            println!("{}", port.port_name);
        }
    }
}
