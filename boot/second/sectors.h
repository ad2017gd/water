#pragma once
#include <stdint.h>

struct DAP {
    uint8_t size;
    uint8_t zero;
    uint16_t sectors;
    uint32_t location;
    uint32_t start_1;
    uint32_t start_2;
}__attribute__((packed));

