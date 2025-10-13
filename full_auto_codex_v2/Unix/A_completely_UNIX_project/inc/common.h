#ifndef COMMON_H
#define COMMON_H

#include <stddef.h>
#include <stdint.h>

typedef struct s_mapped_file
{
	char		*path;
	uint8_t		*data;
	size_t		size;
	int			fd;
}	t_mapped_file;

int		map_file(const char *path, t_mapped_file *out);
void	unmap_file(t_mapped_file *file);
int		ensure_range(const t_mapped_file *file, size_t offset, size_t length);

#endif
