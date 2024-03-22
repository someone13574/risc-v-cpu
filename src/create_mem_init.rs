use std::{fs, io::Write, path::Path};

pub fn create_mem_init<P: AsRef<Path>>(src: P, dst: P) {
    let dst = dst.as_ref();

    let hex_file = std::fs::read_to_string(src).unwrap();
    let file_bytes = hex_file
        .lines()
        .map(|line| line.trim().chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();

    if !dst.exists() {
        fs::create_dir_all(dst).unwrap();
    }

    for file_idx in 0..8 {
        let mut file = fs::File::create(dst.join(format!("eab-init-{}.mif", file_idx))).unwrap();
        file.write_all(
            b"DEPTH = 512;\nWIDTH = 4;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n",
        )
        .unwrap();
        file.write_all(
            file_bytes
                .iter()
                .enumerate()
                .map(|(idx, chars)| {
                    format!(
                        "{}: {};    -- word: {}\n",
                        &hex::encode((idx as u16).to_be_bytes())[1..],
                        chars[file_idx],
                        chars.iter().collect::<String>()
                    )
                })
                .collect::<Vec<_>>()
                .join("")
                .as_bytes(),
        )
        .unwrap();
        if file_bytes.len() != 512 {
            file.write_all(
                format!(
                    "[{}..{}]: 0;\nEND;",
                    &hex::encode((file_bytes.len() as u16).to_be_bytes())[1..],
                    &hex::encode(511_u16.to_be_bytes())[1..]
                )
                .as_bytes(),
            )
            .unwrap();
        }
    }
}
