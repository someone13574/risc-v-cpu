#include <stdint.h>

//  000
// 5   1
// 5   1
//  666
// 4   2
// 4   2
//  333

const uint8_t SEVEN_SEGMENT_LOOKUP[10] = {
    0b00111111, // 0
    0b00000110, // 1
    0b01011011, // 2
    0b01001111, // 3
    0b01100110, // 4
    0b01101101, // 5
    0b01111101, // 6
    0b00000111, // 7
    0b01111111, // 8
    0b01100111, // 9
};

uint16_t encode_seven_segment(uint32_t number)
{
    uint32_t remainder = number;
    uint32_t count = 0;

    while (remainder > 10) {
        remainder -= 10;
        count += 1;
    }

    while (count > 10) {
        count -= 10;
    }

    return ((uint16_t)SEVEN_SEGMENT_LOOKUP[count] << 16) | (uint16_t)SEVEN_SEGMENT_LOOKUP[remainder];
}

void __attribute__((naked)) _start(void)
{
    uint16_t* seven_segments = (uint16_t*)0x7fe;
    *seven_segments = 42;

    uint32_t i = 0;
    while (1) {
        i += 1;
        *seven_segments = encode_seven_segment(i);
    }
}
