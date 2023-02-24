#include "bpb.h"
#include "arguments.h"
#include "fat32_disk_image.h"

#include <stdio.h>

int main(int argc,char ** argv)
{
	Arguments args;
	if(arguments_parser(&args,argv,argc))
	{
		if(args.disk_image_filename)
		{
			Fat32DiskImage img;
			fat32_disk_image_open(&img,args.disk_image_filename);
			
			if(args.bootcode_filename)
			{
				fat32_disk_image_replace_bootcode(&img,args.bootcode_filename);
			}
			fat32_disk_image_close(&img);
		}
	}else
	{
		puts("\x1B[32msaphyra_fs [DISK_IMAGE_FILENAME].img "
			 "--bootcode [BOOTCODE_FILE]\x1B[0m");
		exit(-1);
	}
}
