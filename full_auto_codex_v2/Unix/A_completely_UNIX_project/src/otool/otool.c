#include "ft_otool.h"

#include <stdint.h>
#include <unistd.h>

#include "libft.h"

static void	print_hex64(uint64_t value)
{
	char	buffer[16];
	int	 index;

	index = 15;
	while (index >= 0)
	{
		buffer[index] = "0123456789abcdef"[(value & 0xF)];
		value >>= 4;
		index--;
	}
	write(1, buffer, 16);
}

static void	print_byte(uint8_t value)
{
	char buffer[2];

	buffer[0] = "0123456789abcdef"[value >> 4];
	buffer[1] = "0123456789abcdef"[value & 0xF];
	write(1, buffer, 2);
}

static void	print_text_section(const t_section_info *section, const t_mapped_file *mapped)
{
	size_t		 index;
	size_t		 size;
	const uint8_t	*data;

	ft_putendl_fd("Contents of (__TEXT,__text) section", 1);
	if (ensure_range(mapped, section->offset, section->size) != 0)
		return ;
	data = mapped->data + section->offset;
	size = (size_t)section->size;
	index = 0;
	while (index < size)
	{
		size_t	line_index;

		print_hex64(section->addr + index);
		write(1, "\t", 1);
		line_index = 0;
		while (line_index < 16 && index + line_index < size)
		{
			print_byte(data[index + line_index]);
			line_index++;
			if (line_index % 4 == 0 && line_index < 16 && index + line_index < size)
				write(1, " ", 1);
		}
		write(1, "\n", 1);
		index += 16;
	}
}

int	ft_otool_process(const char *path)
{
	t_mapped_file	mapped;
	t_macho_file	file;
	const t_section_info	*text_section;

	if (map_file(path, &mapped) != 0)
		return (-1);
	if (macho_load(&mapped, &file) != 0)
	{
		ft_putstr_fd("ft_otool: ", 2);
		ft_putstr_fd(path, 2);
		ft_putendl_fd(": unsupported or corrupted file", 2);
		unmap_file(&mapped);
		return (-1);
	}
	ft_putstr_fd(path, 1);
	ft_putendl_fd(":", 1);
	text_section = macho_find_section(&file, "__TEXT", "__text");
	if (text_section == NULL)
	{
		ft_putstr_fd("ft_otool: ", 2);
		ft_putstr_fd(path, 2);
		ft_putendl_fd(": __TEXT,__text section not found", 2);
		macho_unload(&file);
		unmap_file(&mapped);
		return (-1);
	}
	print_text_section(text_section, &mapped);
	macho_unload(&file);
	unmap_file(&mapped);
	return (0);
}
