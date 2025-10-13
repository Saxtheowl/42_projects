#include "ft_nm.h"

#include <stdlib.h>
#include <unistd.h>

#include "libft.h"

typedef struct s_symbol_record
{
	const t_nlist_64	*sym;
	const char		*name;
}t_symbol_record;

static int	symbol_valid(const char *string_table, uint32_t strsize, const t_nlist_64 *sym)
{
	if (sym->n_strx >= strsize)
		return (0);
	if (string_table[sym->n_strx] == '\0')
		return (0);
	return (1);
}

static char	section_letter(const t_macho_file *file, const t_nlist_64 *sym)
{
	const t_section_info	*info;
	char					 letter;

	if (sym->n_sect == 0 || sym->n_sect > file->section_count)
		return ('?');
	info = &file->sections[sym->n_sect - 1];
	if (ft_strncmp(info->segname, "__TEXT", 16) == 0
		&& ft_strncmp(info->sectname, "__text", 16) == 0)
		letter = 'T';
	else if (ft_strncmp(info->segname, "__DATA", 16) == 0
		&& ft_strncmp(info->sectname, "__data", 16) == 0)
		letter = 'D';
	else if (ft_strncmp(info->segname, "__DATA", 16) == 0
		&& ft_strncmp(info->sectname, "__bss", 16) == 0)
		letter = 'B';
	else
		letter = 'S';
	return (letter);
}

static char	symbol_type(const t_macho_file *file, const t_nlist_64 *sym)
{
	uint8_t	type;
	char		letter;

	type = sym->n_type;
	if ((type & N_STAB) != 0)
		return ('\0');
	switch (type & N_TYPE)
	{
	case N_UNDF:
		if (sym->n_value != 0)
			letter = 'C';
		else
			letter = 'U';
		break ;
	case N_ABS:
		letter = 'A';
		break ;
	case N_SECT:
		letter = section_letter(file, sym);
		break ;
	case N_INDR:
		letter = 'I';
		break ;
	default:
		letter = '?';
		break ;
	}
	if ((type & N_EXT) == 0)
		letter = (char)(letter + 32);
	return (letter);
}

static void	print_hex(uint64_t value, size_t width)
{
	char	buffer[32];
	size_t	index;

	if (width >= sizeof(buffer))
		width = sizeof(buffer) - 1;
	index = 0;
	while (index < width)
	{
		size_t	shift;
		uint8_t	nibble;

		shift = (width - 1 - index) * 4;
		nibble = (value >> shift) & 0xF;
		buffer[index] = "0123456789abcdef"[nibble];
		index++;
	}
	write(1, buffer, width);
}

static void	print_symbol_line(const t_nlist_64 *sym, const char *name, char type)
{
	if (type == 'U' || type == 'u')
		write(1, "                ", 16);
	else
		print_hex(sym->n_value, 16);
	write(1, " ", 1);
	write(1, &type, 1);
	write(1, " ", 1);
	ft_putendl_fd(name, 1);
}

static void	sort_symbols(t_symbol_record *symbols, size_t count)
{
	size_t	i;
	size_t	j;

	i = 1;
	while (i < count)
	{
		t_symbol_record	key;

		key = symbols[i];
		j = i;
		while (j > 0 && ft_strcmp(symbols[j - 1].name, key.name) > 0)
		{
			symbols[j] = symbols[j - 1];
			j--;
		}
		symbols[j] = key;
		i++;
	}
}

static int	process_symbols(const t_macho_file *file)
{
	const char			*string_table;
	t_symbol_record		*records;
	size_t				 count;
	size_t				 i;

	string_table = (const char *)(file->mapped->data + file->symtab->stroff);
	records = ft_calloc(file->symtab->nsyms, sizeof(t_symbol_record));
	if (records == NULL)
		return (-1);
	count = 0;
	i = 0;
	while (i < file->symtab->nsyms)
	{
		const t_nlist_64	*sym;

		sym = (const t_nlist_64 *)(file->mapped->data + file->symtab->symoff
			+ i * sizeof(t_nlist_64));
		if (symbol_valid(string_table, file->symtab->strsize, sym))
		{
			char	type;

			type = symbol_type(file, sym);
			if (type != '\0')
			{
				records[count].sym = sym;
				records[count].name = string_table + sym->n_strx;
				count++;
			}
		}
		i++;
	}
	sort_symbols(records, count);
	i = 0;
	while (i < count)
	{
		const t_nlist_64	*sym;
		char			 type;

		sym = records[i].sym;
		type = symbol_type(file, sym);
		print_symbol_line(sym, records[i].name, type);
		i++;
	}
	free(records);
	return (0);
}

int	ft_nm_process(const char *path, int print_header)
{
	t_mapped_file	mapped;
	t_macho_file	file;

	if (map_file(path, &mapped) != 0)
		return (-1);
	if (macho_load(&mapped, &file) != 0)
	{
		ft_putstr_fd("ft_nm: ", 2);
		ft_putstr_fd(path, 2);
		ft_putendl_fd(": unsupported or corrupted file", 2);
		unmap_file(&mapped);
		return (-1);
	}
	if (print_header)
	{
		write(1, "\n", 1);
		ft_putstr_fd(path, 1);
		ft_putendl_fd(":", 1);
	}
	if (process_symbols(&file) != 0)
	{
		ft_putstr_fd("ft_nm: ", 2);
		ft_putstr_fd(path, 2);
		ft_putendl_fd(": failed to process symbols", 2);
		macho_unload(&file);
		unmap_file(&mapped);
		return (-1);
	}
	macho_unload(&file);
	unmap_file(&mapped);
	return (0);
}
