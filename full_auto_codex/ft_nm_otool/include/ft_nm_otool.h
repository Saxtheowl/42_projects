#ifndef FT_NM_OTOOL_H
#define FT_NM_OTOOL_H

#include <elf.h>
#include <stddef.h>

typedef struct s_mapped_file
{
	void	*addr;
	size_t	size;
}	t_mapped_file;

typedef struct s_symbol
{
	const char	*name;
	Elf64_Sym	sym;
}	t_symbol;

int		map_file(const char *path, t_mapped_file *out);
void	unmap_file(t_mapped_file *file);

int		validate_elf64(const t_mapped_file *file, Elf64_Ehdr **ehdr);
int		load_symbols(const t_mapped_file *file, const Elf64_Ehdr *ehdr,
			t_symbol **out_symbols, size_t *out_count);
char	resolve_symbol_type(const Elf64_Sym *sym, const Elf64_Shdr *sections, size_t section_count);

int		print_nm(const char *path);
int		print_otool(const char *path);

void	*offset_ptr(const t_mapped_file *file, size_t offset, size_t size);
const char	*safe_string(const t_mapped_file *file, const char *base, size_t offset);

#endif
