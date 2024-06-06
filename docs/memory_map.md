# Memory Map

The memory of this CPU consists of 8 EABs (embedded array blocks) each of which are in the 512x4 configuration, resulting in 512 words which are 32 bit each, or 2 KiB of memory. This memory is mapped to addresses `0x0` to `0x7ff`.

Beyond the address `0x7ff` is Memory Mapped IO (`mmio`). From `0x800` to `0xbff` is assigned to mmio. All MMIO is word-aligned and can only be read or written as a full 32 bits. Some MMIO is marked as read-only and will ignore write operations.

<table>
<thead>
  <tr>
    <th>Type</th>
    <th>Address<br></th>
    <th>Region Name<br></th>
    <th>Contents</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="3">ROM (in RAM)</td>
    <td rowspan="3">0x0</td>
    <td>.text*._start</td>
    <td>Program entry point</td>
  </tr>
  <tr>
    <td>.text*</td>
    <td>Executable code</td>
  </tr>
  <tr>
    <td>.rodata*</td>
    <td>Read only data (global constants)</td>
  </tr>
  <tr>
    <td rowspan="4">RAM</td>
    <td rowspan="2">0x400</td>
    <td>.data*</td>
    <td>Global variables initialized at compile time</td>
  </tr>
  <tr>
    <td>.bss*</td>
    <td>Uninitialized global variables</td>
  </tr>
  <tr>
    <td>0x700</td>
    <td>.stack _stack_top<br></td>
    <td>Top of the stack</td>
  </tr>
  <tr>
    <td>0x7ff</td>
    <td>.stack _stack_bottom</td>
    <td>Bottom of the stack</td>
  </tr>
  <tr>
    <td rowspan="3">MMIO</td>
    <td>0x800</td>
    <td>seven_segment<br></td>
    <td>UP2's FLEX_DIGIT seven segment displays</td>
  </tr>
  <tr>
    <td>0x804</td>
    <td>uart_tx_data</td>
    <td>Byte to send over the uart</td>
  </tr>
  <tr>
    <td>0x808</td>
    <td>uart_tx_sending</td>
    <td>Current status of the uart transmitter. 0 = idle, 1 = active. Read only.</td>
  </tr>
</tbody>
</table>
