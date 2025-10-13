#include "common.h"

#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#include "libft.h"

static int	print_error(const char *path, const char *message)
{
	ft_putstr_fd("ft_nm_otool: ", 2);
	ft_putstr_fd(path, 2);
	ft_putstr_fd(": ", 2);
	ft_putendl_fd(message, 2);
	return (-1);
}

int	map_file(const char *path, t_mapped_file *out)
{
	struct stat	sb;

	out->path = (char *)path;
	out->data = NULL;
	out->size = 0;
	out->fd = open(path, O_RDONLY);
	if (out->fd < 0)
		return (print_error(path, "cannot open file"));
	if (fstat(out->fd, &sb) != 0)
	{
		close(out->fd);
		return (print_error(path, "fstat failed"));
	}
	if (sb.st_size == 0)
	{
		close(out->fd);
		return (print_error(path, "empty file"));
	}
	out->size = (size_t)sb.st_size;
	out->data = mmap(NULL, out->size, PROT_READ, MAP_PRIVATE, out->fd, 0);
	if (out->data == MAP_FAILED)
	{
		close(out->fd);
		out->data = NULL;
		return (print_error(path, "mmap failed"));
	}
	return (0);
}

void	unmap_file(t_mapped_file *file)
{
	if (file->data != NULL && file->data != MAP_FAILED)
		munmap(file->data, file->size);
	if (file->fd >= 0)
		close(file->fd);
	file->data = NULL;
	file->size = 0;
	file->fd = -1;
}

int	ensure_range(const t_mapped_file *file, size_t offset, size_t length)
{
	if (offset > file->size || length > file->size || offset + length > file->size)
		return (-1);
	return (0);
}
