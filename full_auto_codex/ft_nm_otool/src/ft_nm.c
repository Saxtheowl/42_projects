#include "ft_nm_otool.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int symbol_cmp(const void *a, const void *b)
{
	const t_symbol *sa = (const t_symbol *)a;
	const t_symbol *sb = (const t_symbol *)b;
	int cmp;

	cmp = strcmp(sa->name, sb->name);
	if (cmp != 0)
		return cmp;
	if (sa->sym.st_value < sb->sym.st_value)
		return -1;
	if (sa->sym.st_value > sb->sym.st_value)
		return 1;
	return 0;
}

static void print_symbol(const Elf64_Shdr *sections, size_t section_count, const t_symbol *symbol)
{
	char type = resolve_symbol_type(&symbol->sym, sections, section_count);

	if (type == ' ')
		return ;
	if (symbol->sym.st_shndx == SHN_UNDEF)
		printf("%16s %c %s\n", "", type, symbol->name);
	else
		printf("%016lx %c %s\n", (unsigned long)symbol->sym.st_value, type, symbol->name);
}

int print_nm(const char *path)
{
	t_mapped_file	file;
	Elf64_Ehdr	*ehdr;
	t_symbol	*symbols;
	size_t		count;
	int		ret;

	if (map_file(path, &file) != 0)
	{
		fprintf(stderr, "ft_nm: %s: cannot open file\n", path);
		return (1);
	}
	ret = 0;
	if (validate_elf64(&file, &ehdr) != 0)
	{
		fprintf(stderr, "ft_nm: %s: unsupported file\n", path);
		ret = 1;
		goto cleanup;
	}
	if (load_symbols(&file, ehdr, &symbols, &count) != 0)
	{
		fprintf(stderr, "ft_nm: %s: no symbols\n", path);
		ret = 1;
		goto cleanup;
	}
	qsort(symbols, count, sizeof(t_symbol), symbol_cmp);
	const Elf64_Shdr *sections = (const Elf64_Shdr *)((const char *)file.addr + ehdr->e_shoff);
	for (size_t i = 0; i < count; ++i)
		print_symbol(sections, ehdr->e_shnum, &symbols[i]);
	free(symbols);
cleanup:
	unmap_file(&file);
	return ret;
}
