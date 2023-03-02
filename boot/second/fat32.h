#include <stdint.h>
#pragma once


typedef struct
{
	unsigned char 		bootjmp[3];
	unsigned char 		oem_name[8];
	unsigned short 	        bytes_per_sector;
	unsigned char		sectors_per_cluster;
	unsigned short		reserved_sector_count;
	unsigned char		table_count;
	unsigned short		root_entry_count;
	unsigned short		total_sectors_16;
	unsigned char		media_type;
	unsigned short		table_size_16;
	unsigned short		sectors_per_track;
	unsigned short		head_side_count;
	uint32_t 		hidden_sector_count;
	uint32_t 		total_sectors_32;
 
	uint32_t		table_size_32;
	unsigned short		extended_flags;
	unsigned short		fat_version;
	uint32_t		root_cluster;
	unsigned short		fat_info;
	unsigned short		backup_BS_sector;
	unsigned char 		reserved_0[12];
	unsigned char		drive_number;
	unsigned char 		reserved_1;
	unsigned char		boot_signature;
	uint32_t 		volume_id;
	unsigned char		volume_label[11];
	unsigned char		fat_type_label[8];
 
 
}__attribute__((packed)) fat32;


typedef struct {
    unsigned char name[11];
    unsigned char attribute;
    unsigned char __reserved;
    unsigned char creationTenthSecond;
    unsigned short creationTime;
    unsigned short creationDate;
    unsigned short lastAccessDate;
    unsigned short startClusterHigh;
    unsigned short lastModificationTime;
    unsigned short lastModificationDate;
    unsigned short startClusterLow;
    uint32_t fileSize;
} __attribute__((packed)) fat32_dir_entry;

typedef unsigned short widechar;

typedef struct {
    unsigned char order;
    widechar name_1[5];
    unsigned char attribute;
    unsigned char type;
    unsigned char checksum;
    widechar name_2[6];
    unsigned short __zero;
    widechar name_3[2];
} __attribute__((packed)) fat32_lfn;