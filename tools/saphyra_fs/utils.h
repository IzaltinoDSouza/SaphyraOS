#pragma once

#include <string.h>
#include <stdbool.h>

bool begin_with(char * str,char * pattern)
{
	size_t pattern_length = strlen(pattern);
	return strncmp(str,pattern,pattern_length) == 0;
}
bool end_with(char * str,char * pattern)
{
	size_t str_length = strlen(str);
	size_t pattern_length = strlen(pattern);
	
	char * begin = str + (str_length-pattern_length);
	return strcmp(begin,pattern) == 0;
}
