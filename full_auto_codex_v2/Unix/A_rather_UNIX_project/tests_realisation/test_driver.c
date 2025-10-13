#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef void (*t_show_fn)(void);

static int	test_basic(void)
{
	char	*ptr;

	ptr = (char *)malloc(32);
	if (!ptr)
		return (1);
	memcpy(ptr, "hello world", 12);
	printf("%s\n", ptr);
	free(ptr);
	return (0);
}

static int	test_realloc(void)
{
	char	*ptr;
	char	*new_ptr;

	ptr = (char *)malloc(64);
	if (!ptr)
		return (1);
	memset(ptr, 'A', 63);
	ptr[63] = '\0';
	new_ptr = (char *)realloc(ptr, 256);
	if (!new_ptr)
		return (1);
	printf("%d %d %d %d\n", new_ptr[0], new_ptr[1], new_ptr[62], new_ptr[63]);
	free(new_ptr);
	return (0);
}

static int	test_large(void)
{
	char	*ptr;

	ptr = (char *)malloc(16384);
	if (!ptr)
		return (1);
	ptr[0] = 'L';
	ptr[16383] = 'X';
	printf("%c%c\n", ptr[0], ptr[16383]);
	free(ptr);
	return (0);
}

static int	test_show(void)
{
	char	*tiny;
	char	*small;
	char	*large;
	 t_show_fn	show_fn;

	tiny = (char *)malloc(128);
	if (!tiny)
		return (1);
	small = (char *)malloc(900);
	if (!small)
		return (1);
	large = (char *)malloc(16384);
	if (!large)
		return (1);
	memset(tiny, 0, 128);
	memset(small, 0, 900);
	memset(large, 0, 16384);
	show_fn = (t_show_fn)dlsym(RTLD_DEFAULT, "show_alloc_mem");
	if (!show_fn)
		return (1);
	show_fn();
	free(tiny);
	free(small);
	free(large);
	return (0);
}

int	main(int argc, char **argv)
{
	if (argc < 2)
		return (1);
	if (strcmp(argv[1], "basic") == 0)
		return (test_basic());
	if (strcmp(argv[1], "realloc") == 0)
		return (test_realloc());
	if (strcmp(argv[1], "large") == 0)
		return (test_large());
	if (strcmp(argv[1], "show") == 0)
		return (test_show());
	return (1);
}
