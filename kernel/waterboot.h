#include <stdint.h>

// kernel to bootloader data
typedef struct {
    unsigned char magic[10]; // "WATERBOOT"
    uint8_t videoMode;
} waterboot_req_t;