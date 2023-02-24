/*
	SaphyraOS © All Right Reserved
	Author  : IzaltinoDSouza
	Date    : February 24,2023
*/
#pragma once

#include <stdio.h>
#include <stddef.h>
#include "utils.h"

typedef struct
{
	char * disk_image_filename;
	char * bootcode_filename;
}Arguments;

bool arguments_parser_bootcode(Arguments * args,
							   char ** list_args,
							   size_t args_total,
							   size_t current_num_arg)
{
	if(begin_with(list_args[current_num_arg],"--bootcode"))
	{
		if((current_num_arg+1) < args_total)
		{
			if(!begin_with(list_args[current_num_arg+1],"--"))
			{			
				args->bootcode_filename = list_args[current_num_arg+1];
				return true;
			}
		}
	}	
	printf("\x1B[31m error \x1B[0m  : %s need to have a paramenter \n",
		   list_args[current_num_arg]);
	return false;
}
bool arguments_parser(Arguments * args,char ** list_args,size_t num_args)
{
	args->disk_image_filename = NULL;
	args->bootcode_filename   = NULL;
	if(num_args > 1)
	{
		for(size_t i = 1;i < num_args;++i)
		{
			if(end_with(list_args[i],".img"))
			{
				args->disk_image_filename = list_args[i];
			}else if(begin_with(list_args[i],"--"))
			{
				if(begin_with(list_args[i],"--bootcode"))
					return arguments_parser_bootcode(args,list_args,num_args,i);
				else
					printf("\x1B[33m warning \x1B[0m: unsupported argument '%s'\n",
						   list_args[i]);
			}
		}
		return true;
	}else
	{
		return false;
	}	
}
