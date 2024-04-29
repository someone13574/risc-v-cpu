#include <stdint.h>

//  000
// 5   1
// 5   1
//  666
// 4   2
// 4   2
//  333

const uint8_t SEVEN_SEGMENT_LOOKUP[16] = {
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
    0b01110111, // A
    0b01111100, // B
    0b00111001, // C
    0b01011110, // D
    0b01111001, // E
    0b01110001, // F
};

uint16_t encode_seven_segment(uint32_t number)
{
    // uint32_t remainder = number;
    // uint32_t count = 0;

    // while (remainder > 10) {
    //     remainder -= 10;
    //     count += 1;
    // }

    // while (count > 10) {
    //     count -= 10;
    // }

    return ((uint16_t)SEVEN_SEGMENT_LOOKUP[(number >> 4) & 0b1111] << 8) | (uint16_t)SEVEN_SEGMENT_LOOKUP[number & 0b1111];
}

void __attribute__((naked)) _start(void)
{
    uint16_t* seven_segments = (uint16_t*)0x7fe;
    uint32_t i = 0;
    while (1) {
        i += 1;
        *seven_segments = encode_seven_segment(i);

        for (uint32_t n = 0; n < 1000000; n++) { }
    }
}
