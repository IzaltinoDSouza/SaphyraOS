/*
	SaphyraOS © All Right Reserved
	Author  : IzaltinoDSouza
	Date    : February 13,2023 (original)
			  February 24,2023 (rewrite)
*/
#pragma once

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct
{
	BIOSParameterBlock * bpb;
	FILE * disk_image;
}Fat32DiskImage;

void fat32_disk_image_open(Fat32DiskImage * img,
						   char * img_filename)
{
	img->disk_image = fopen(img_filename,"r+b");
	if(!img->disk_image)
	{
		printf("\x1B[31m'%s' not found\x1B[0m\n",img_filename);
		exit(-1);
	}
	img->bpb = malloc(sizeof(BIOSParameterBlock));
	fread(img->bpb,sizeof(BIOSParameterBlock),1,img->disk_image);
}
void fat32_disk_image_read_sector(Fat32DiskImage * img,
								  size_t sector,
								  uint8_t * data,
								  size_t count)
{
	fseek(img->disk_image,sector*img->bpb->BPB_BytesPerSec,SEEK_SET);
	fread(data,img->bpb->BPB_BytesPerSec*count,1,img->disk_image);
}
void fat32_disk_image_write_sector(Fat32DiskImage * img,
								   size_t sector,
								   uint8_t * data,
								   size_t count)
{
	fseek(img->disk_image,sector*img->bpb->BPB_BytesPerSec,SEEK_SET);
	fwrite(data,img->bpb->BPB_BytesPerSec*count,1,img->disk_image);
}

void fat32_disk_image_replace_bootcode(Fat32DiskImage * img,
									   char * bootcode_filename)
{
	FILE * fp = fopen(bootcode_filename,"rb");
	if(fp)
	{
		fseek(fp,0,SEEK_END);
		size_t size = ftell(fp);
		fseek(fp,0,SEEK_SET);
		if(size <= BOOTCODE_SIZE)
		{
			printf("\x1B[32mbootcode %ld/%d bytes\x1B[0m\n",size,BOOTCODE_SIZE);
			fread(img->bpb->bootcode,size,1,fp);
			
			//fill rest of bootcode with zero
			memset(&img->bpb->bootcode[size],0,BOOTCODE_SIZE-size);
			
			//set jmp boot to jump at offset of bootcode
			memcpy(&img->bpb->BS_jmpBoot,g_asm_jmpboot,3);
			
			for(size_t i = 0;i < BOOTCODE_SIZE;++i)
			{
				printf("%02x ", img->bpb->bootcode[i]);
			}
			
			//flush bpb
			fat32_disk_image_write_sector(img,0,(uint8_t*)img->bpb,1);
		}else
		{
			printf("\x1B[31mbootcode is too big %ld/%d bytes\x1B[0m\n",
				   size,
				   BOOTCODE_SIZE);
		}
		
		fclose(fp);
	}else
	{
		printf("\x1B[31m'%s' not found\x1B[0m\n",bootcode_filename);
		exit(-1);
	}	
}
void fat32_disk_image_close(Fat32DiskImage * img)
{
	free(img->bpb);
	fclose(img->disk_image);
}
