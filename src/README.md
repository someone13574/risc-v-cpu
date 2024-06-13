## CLI

This is an overview of the supporting CLI.

#### General Usage

> [!NOTE]
> If you are running through cargo, use `cargo run -- <COMMAND>` instead of `risc-v-cpu-cli <COMMAND>`.

```
Usage: risc-v-cpu-cli <COMMAND>

Commands:
  generate-microcode  Generate the microcode rom data
  create-mem-init     Create memory initialization file from a hex file
  upload-program      Upload to program over uart
  help                Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help
```

#### Generating the Microcode

Though the microcode `.mem` file is already committed in the repository, you can regenerate it using this command. Note that by default, this will not overwrite the file and instead will only output to STDOUT. Use the `--write` option to overwrite the file.

```
Generate the microcode rom data

Usage: risc-v-cpu-cli generate-microcode [OPTIONS]

Options:
  -w, --write  Overwrite `microcode.mem` in the system verilog design
  -h, --help   Print help
```

#### Creating Memory Initialization Files

> [!WARN]
> This CPU no longer uses memory initialization files and thus this will not do anything without changing the design files to initialize from files, as well as disabling the uart updating logic.

> [!NOTE]
> You will need to compile the C program before using this.

```
Create memory initialization file from a hex file

Usage: risc-v-cpu-cli create-mem-init <HEX_FILE> <DST>

Arguments:
  <HEX_FILE>
  <DST>

Options:
  -h, --help  Print help
```

#### Uploading Over UART

> [!NOTE]
> You will need to compile the C program before using this.

To upload over UART, reset the CPU and then run this command. It will then upload the program over a UART connector (or a usb-to-uart connector). If you obmit the port option, the program will print the available ports.

```
Upload to program over uart

Usage: risc-v-cpu-cli upload-program <HEX_FILE> [PORT]

Arguments:
  <HEX_FILE>
  [PORT]

Options:
  -h, --help  Print help
```
