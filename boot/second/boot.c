
#include "sectors.h"
#include "fat32.h"
#include <stdarg.h>
#include <stdint.h>




#define DAP_SIZE 0x10


struct DAP dap = {.size=DAP_SIZE, .location=0xB000, .sectors=8, .zero = 0, .start_2 = 0};


void readSectors64k(struct DAP* dap) {
    asm (
        "mov si, %0\n"
        "mov dl, 0x80\n"
        "mov ah, 0x42\n"
        "int 0x13" 
    ::"g"((short)dap):"ah","dl","si");
    
}

int strcmp_s(const char* s1, const char* s2, int len)
{
    len--;
    while(len-- && (*s1 == *s2))
    {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}
int strcmp(const char* s1, const char* s2)
{
    while(*s1 && (*s1 == *s2))
    {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

fat32* fat_boot = 0x7c00;
uint32_t first_data_sector;

fat32_dir_entry* findFile8_3(void* memory, char* file) {

    // Try for the loaded 8 sectors ONLY
    for(int offset = 0; offset < 8 * 512 / 32; offset += 32) {
        fat32_lfn* LFN = memory+offset;
        if(LFN->attribute == 0x0F) {
            // Don't need
            continue;
        } else {
            fat32_dir_entry* dir = memory+offset;
            if(!strcmp_s(dir->name, file, 11)) {
                // Found file
                return dir;
            }
        }
    }
    return 0;
}

void* loadFile8_3(uint32_t memory, fat32_dir_entry* file) {
    uint32_t cluster = (file->startClusterHigh << 16) + file->startClusterLow - 2;
    uint16_t sectors_to_read = (file->fileSize+511) / 512;
    uint32_t first_sector = cluster * fat_boot->sectors_per_cluster + first_data_sector;

    dap.location = memory;
    dap.sectors = sectors_to_read;
    dap.start_1 = first_sector;
    

    debug_print("Loaded ");
    debug_printl(file->name, 11);
    debug_print(" ... ");

    readSectors64k(&dap);
    return memory;
}



void __attribute__((noreturn)) __attribute__((section("__start"))) main(){
    asm("mov     ax,0x2401\n"
        "int     0x15\n"
        "in al, 0x92\n"
        "or al, 2\n"
        "out 0x92, al\n");
    debug_print("WATERBOOT: LOADED BOOT.BIN ... ");
    first_data_sector = fat_boot->reserved_sector_count + (fat_boot->table_count * fat_boot->table_size_32);
    dap.start_1 = first_data_sector;
    dap.location = 0xA000;
    readSectors64k(&dap);
    fat32_dir_entry* kernel_dir_entry = findFile8_3(0xA000, "1KERNEL BIN");
    // load kernel temp 0x10000
    char* kernel_bin_data = loadFile8_3(0x10000000, kernel_dir_entry);
    
    
    asm("mov ax, %0\njmp jumpToProtected\n"
    ::"r"(kernel_dir_entry->fileSize):);


    while(1){};
    asm("hlt");
}











void debug_print(char* c) {
    int i = 0;
    while(c[i] != 0) {
        debug_putchar(c[i++]);
    }
}
void debug_printl(char* c, int l) {
    int i = 0;
    while(i < l) {
        debug_putchar(c[i++]);
    }
}
void debug_putchar(char c) {
    asm(
        "mov al, %0\n"
        "mov ah, 0x0e\n"
        "int 0x10" 
        ::"g"((char)c):"ax");
    
}
