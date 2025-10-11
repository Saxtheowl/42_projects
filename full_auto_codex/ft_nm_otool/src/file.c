#include "ft_nm_otool.h"

#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

int	map_file(const char *path, t_mapped_file *out)
{
	struct stat	st;
	void		*addr;
	int			fd;

	if (!path || !out)
		return (-1);
	fd = open(path, O_RDONLY);
	if (fd < 0)
		return (-1);
	if (fstat(fd, &st) < 0)
	{
		close(fd);
		return (-1);
	}
	if (st.st_size == 0)
	{
		close(fd);
		return (-1);
	}
	addr = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	close(fd);
	if (addr == MAP_FAILED)
		return (-1);
	out->addr = addr;
	out->size = (size_t)st.st_size;
	return (0);
}

void	unmap_file(t_mapped_file *file)
{
	if (!file || !file->addr || file->size == 0)
		return ;
	munmap(file->addr, file->size);
	file->addr = NULL;
	file->size = 0;
}

void	*offset_ptr(const t_mapped_file *file, size_t offset, size_t size)
{
	size_t	end;

	if (!file || !file->addr)
		return NULL;
	if (offset > file->size)
		return NULL;
	end = offset + size;
	if (end < offset || end > file->size)
		return NULL;
	return (void *)((char *)file->addr + offset);
}

const char	*safe_string(const t_mapped_file *file, const char *base, size_t offset)
{
	const char	*ptr;
	const char	*end;

	ptr = base + offset;
	if (ptr < (const char *)file->addr || ptr >= (const char *)file->addr + file->size)
		return NULL;
	end = (const char *)file->addr + file->size;
	while (ptr < end && *ptr)
		ptr++;
	if (ptr == end)
		return NULL;
	return base + offset;
}
