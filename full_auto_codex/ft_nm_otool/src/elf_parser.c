#include "ft_nm_otool.h"

#include <stdlib.h>
#include <string.h>

int	validate_elf64(const t_mapped_file *file, Elf64_Ehdr **ehdr)
{
	Elf64_Ehdr	*header;

	if (!file || !file->addr || file->size < sizeof(Elf64_Ehdr))
		return (-1);
	header = (Elf64_Ehdr *)file->addr;
	if (memcmp(header->e_ident, ELFMAG, SELFMAG) != 0)
		return (-1);
	if (header->e_ident[EI_CLASS] != ELFCLASS64)
		return (-1);
	if (header->e_ident[EI_DATA] != ELFDATA2LSB)
		return (-1);
	if (header->e_shoff >= file->size)
		return (-1);
	if (header->e_shentsize != sizeof(Elf64_Shdr))
		return (-1);
	if ((size_t)header->e_shoff + (size_t)header->e_shnum * sizeof(Elf64_Shdr) > file->size)
		return (-1);
	*ehdr = header;
	return (0);
}

static int	load_strtab(const t_mapped_file *file, const Elf64_Shdr *strtab,
		const char **out)
{
	if (!strtab || strtab->sh_offset >= file->size)
		return (-1);
	if (strtab->sh_offset + strtab->sh_size > file->size)
		return (-1);
	*out = (const char *)file->addr + strtab->sh_offset;
	return (0);
}

static size_t	count_symbols(const Elf64_Shdr *symtab)
{
	if (!symtab || symtab->sh_entsize == 0)
		return 0;
	return symtab->sh_size / symtab->sh_entsize;
}

int	load_symbols(const t_mapped_file *file, const Elf64_Ehdr *ehdr,
			t_symbol **out_symbols, size_t *out_count)
{
	const Elf64_Shdr	*sections;
	const Elf64_Shdr	*symtab = NULL;
	const Elf64_Shdr	*strtab = NULL;
	t_symbol			*symbols;
	size_t				count;
	size_t				i;
	const char			*strs;

	sections = (const Elf64_Shdr *)((const char *)file->addr + ehdr->e_shoff);
	for (i = 0; i < ehdr->e_shnum; ++i)
	{
		if (sections[i].sh_type == SHT_SYMTAB)
		{
			symtab = &sections[i];
			if (symtab->sh_link < ehdr->e_shnum)
				strtab = &sections[symtab->sh_link];
			break ;
		}
	}
	if (!symtab || !strtab)
		return (-1);
	if (load_strtab(file, strtab, &strs) != 0)
		return (-1);
	count = count_symbols(symtab);
	if (count == 0)
		return (-1);
	if (symtab->sh_offset + symtab->sh_size > file->size)
		return (-1);
	symbols = (t_symbol *)malloc(sizeof(t_symbol) * count);
	if (!symbols)
		return (-1);
	const Elf64_Sym *table = (const Elf64_Sym *)((const char *)file->addr + symtab->sh_offset);
	for (i = 0; i < count; ++i)
	{
		symbols[i].sym = table[i];
		if (table[i].st_name < strtab->sh_size)
			symbols[i].name = safe_string(file, strs, table[i].st_name);
		else
			symbols[i].name = NULL;
		if (!symbols[i].name)
			symbols[i].name = "";
	}
	*out_symbols = symbols;
	*out_count = count;
	return (0);
}

static int	is_section_text(const Elf64_Shdr *section)
{
	return (section->sh_type == SHT_PROGBITS && (section->sh_flags & SHF_EXECINSTR));
}

char	resolve_symbol_type(const Elf64_Sym *sym, const Elf64_Shdr *sections, size_t section_count)
{
	char	c;
	unsigned char	type;
	const Elf64_Shdr	*sec;

	type = ELF64_ST_TYPE(sym->st_info);
	if (type == STT_FILE)
		return ' ';
	if (ELF64_ST_BIND(sym->st_info) == STB_GNU_UNIQUE)
		return 'u';
	if (ELF64_ST_BIND(sym->st_info) == STB_WEAK)
	{
		if (type == STT_OBJECT)
			c = 'v';
		else
			c = 'w';
		return (sym->st_shndx == SHN_UNDEF) ? c - 32 : c;
	}
	if (sym->st_shndx == SHN_UNDEF)
		return 'U';
	if (sym->st_shndx == SHN_ABS)
		return 'A';
	if (sym->st_shndx == SHN_COMMON)
		return 'C';
	if (!sections || sym->st_shndx >= section_count)
		return '?';
	sec = &sections[sym->st_shndx];
	if (is_section_text(sec))
		c = 'T';
	else if (sec->sh_type == SHT_NOBITS && (sec->sh_flags & SHF_ALLOC) && (sec->sh_flags & SHF_WRITE))
		c = 'B';
	else if ((sec->sh_flags & SHF_ALLOC) && (sec->sh_flags & SHF_WRITE))
		c = 'D';
	else if (sec->sh_flags & SHF_ALLOC)
		c = 'R';
	else
		c = 'N';
	if (ELF64_ST_BIND(sym->st_info) == STB_LOCAL)
		c = (char)(c + 32);
	return c;
}
