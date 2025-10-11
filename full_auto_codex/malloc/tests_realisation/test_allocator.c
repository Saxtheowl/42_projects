#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <dlfcn.h>

static int check_pattern(char *ptr, size_t size, char value)
{
	for (size_t i = 0; i < size; ++i)
	{
		if (ptr[i] != value)
			return 0;
	}
	return 1;
}

int main(void)
{
	char *tiny = malloc(32);
	char *small = malloc(600);
	char *large = malloc(5000);

	if (!tiny || !small || !large)
	{
		fprintf(stderr, "allocation failed\n");
		return 1;
	}

	memset(tiny, 'A', 32);
	memset(small, 'B', 600);
	memset(large, 'C', 5000);

	small = realloc(small, 800);
	if (!small || !check_pattern(small, 600, 'B'))
	{
		fprintf(stderr, "realloc small failed\n");
		return 1;
	}

	large = realloc(large, 9000);
	if (!large || !check_pattern(large, 5000, 'C'))
	{
		fprintf(stderr, "realloc large failed\n");
		return 1;
	}

	free(tiny);
	free(small);
	free(large);

	void (*show_alloc_mem)(void) = (void (*)(void))dlsym(RTLD_DEFAULT, "show_alloc_mem");
	if (show_alloc_mem)
		show_alloc_mem();

	return 0;
}
