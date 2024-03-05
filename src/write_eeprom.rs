use std::{path::Path, time::Duration};

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

        let bytes_to_write = std::fs::read_to_string(path)
            .unwrap()
            .lines()
            .flat_map(|line| hex::decode(line.trim()).unwrap())
            .collect::<Vec<_>>();

        let mut port = serialport::new(port, 9600)
            .timeout(Duration::from_secs(1))
            .open()
            .unwrap();

        let mut response_buffer: Vec<u8> = vec![0; 5];
        port.read_exact(response_buffer.as_mut_slice()).unwrap();
        assert_eq!(response_buffer, b"start");

        for byte_chunk in bytes_to_write.chunks(32) {
            port.write_all(byte_chunk).unwrap();

            let mut response_buffer: Vec<u8> = vec![0; 1];
            port.read_exact(response_buffer.as_mut_slice()).unwrap();

            if response_buffer[0] != 42 {
                panic!("Didn't receive correct write ack. Ensure the arduino is running the correct program.");
            }
        }
    } else {
        println!("No port supplied. Available ports:");
        for port in ports {
            println!("{}", port.port_name);
        }
    }
}
