/* ************************************************************************** */
/*                                                                            */
/*   ft_nm - List symbols from object files                                   */
/*   Displays the symbol table of ELF binaries                                */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <elf.h>

typedef struct s_nm
{
	void	*data;
	size_t	size;
	int		is_64bit;
}	t_nm;

static char	get_symbol_type_32(Elf32_Sym *sym, Elf32_Shdr *shdr)
{
	unsigned char	bind;
	unsigned char	type;
	char			c;

	bind = ELF32_ST_BIND(sym->st_info);
	type = ELF32_ST_TYPE(sym->st_info);

	if (bind == STB_GNU_UNIQUE)
		return ('u');
	if (bind == STB_WEAK)
	{
		c = 'w';
		if (sym->st_shndx != SHN_UNDEF)
			c = 'W';
		if (type == STT_OBJECT)
			c = (sym->st_shndx == SHN_UNDEF) ? 'v' : 'V';
		return (c);
	}
	if (sym->st_shndx == SHN_UNDEF)
		return ('U');
	if (sym->st_shndx == SHN_ABS)
		return ('A');
	if (sym->st_shndx == SHN_COMMON)
		return ('C');

	if (shdr)
	{
		if (shdr->sh_type == SHT_NOBITS && (shdr->sh_flags & SHF_ALLOC))
			c = 'B';
		else if (shdr->sh_flags & SHF_EXECINSTR)
			c = 'T';
		else if (shdr->sh_flags & SHF_WRITE)
			c = 'D';
		else if (shdr->sh_flags & SHF_ALLOC)
			c = 'R';
		else
			c = 'N';

		if (bind == STB_LOCAL)
			c += 32;  /* lowercase */
		return (c);
	}
	return ('?');
}

static char	get_symbol_type_64(Elf64_Sym *sym, Elf64_Shdr *shdr)
{
	unsigned char	bind;
	unsigned char	type;
	char			c;

	bind = ELF64_ST_BIND(sym->st_info);
	type = ELF64_ST_TYPE(sym->st_info);

	if (bind == STB_GNU_UNIQUE)
		return ('u');
	if (bind == STB_WEAK)
	{
		c = 'w';
		if (sym->st_shndx != SHN_UNDEF)
			c = 'W';
		if (type == STT_OBJECT)
			c = (sym->st_shndx == SHN_UNDEF) ? 'v' : 'V';
		return (c);
	}
	if (sym->st_shndx == SHN_UNDEF)
		return ('U');
	if (sym->st_shndx == SHN_ABS)
		return ('A');
	if (sym->st_shndx == SHN_COMMON)
		return ('C');

	if (shdr)
	{
		if (shdr->sh_type == SHT_NOBITS && (shdr->sh_flags & SHF_ALLOC))
			c = 'B';
		else if (shdr->sh_flags & SHF_EXECINSTR)
			c = 'T';
		else if (shdr->sh_flags & SHF_WRITE)
			c = 'D';
		else if (shdr->sh_flags & SHF_ALLOC)
			c = 'R';
		else
			c = 'N';

		if (bind == STB_LOCAL)
			c += 32;
		return (c);
	}
	return ('?');
}

static int	process_64(t_nm *nm)
{
	Elf64_Ehdr	*ehdr;
	Elf64_Shdr	*shdr;
	Elf64_Shdr	*symtab;
	Elf64_Shdr	*strtab_hdr;
	Elf64_Sym	*syms;
	char		*strtab;
	size_t		i;
	size_t		sym_count;

	ehdr = (Elf64_Ehdr *)nm->data;
	shdr = (Elf64_Shdr *)((char *)nm->data + ehdr->e_shoff);

	/* Find symbol table */
	symtab = NULL;
	for (i = 0; i < ehdr->e_shnum; i++)
	{
		if (shdr[i].sh_type == SHT_SYMTAB)
		{
			symtab = &shdr[i];
			break;
		}
	}

	if (!symtab)
	{
		/* Try dynsym */
		for (i = 0; i < ehdr->e_shnum; i++)
		{
			if (shdr[i].sh_type == SHT_DYNSYM)
			{
				symtab = &shdr[i];
				break;
			}
		}
	}

	if (!symtab)
	{
		fprintf(stderr, "no symbols\n");
		return (1);
	}

	strtab_hdr = &shdr[symtab->sh_link];
	syms = (Elf64_Sym *)((char *)nm->data + symtab->sh_offset);
	strtab = (char *)nm->data + strtab_hdr->sh_offset;
	sym_count = symtab->sh_size / sizeof(Elf64_Sym);

	/* Print symbols */
	for (i = 1; i < sym_count; i++)  /* Skip null symbol */
	{
		char		*name;
		char		type;
		Elf64_Shdr	*sec;

		name = strtab + syms[i].st_name;
		if (!name[0])
			continue;

		sec = NULL;
		if (syms[i].st_shndx < ehdr->e_shnum)
			sec = &shdr[syms[i].st_shndx];

		type = get_symbol_type_64(&syms[i], sec);

		if (syms[i].st_value != 0 || type == 'T' || type == 't' ||
			type == 'D' || type == 'd' || type == 'B' || type == 'b' ||
			type == 'R' || type == 'r')
			printf("%016lx %c %s\n", syms[i].st_value, type, name);
		else
			printf("%18s %c %s\n", "", type, name);
	}
	return (0);
}

static int	process_32(t_nm *nm)
{
	Elf32_Ehdr	*ehdr;
	Elf32_Shdr	*shdr;
	Elf32_Shdr	*symtab;
	Elf32_Shdr	*strtab_hdr;
	Elf32_Sym	*syms;
	char		*strtab;
	size_t		i;
	size_t		sym_count;

	ehdr = (Elf32_Ehdr *)nm->data;
	shdr = (Elf32_Shdr *)((char *)nm->data + ehdr->e_shoff);

	/* Find symbol table */
	symtab = NULL;
	for (i = 0; i < ehdr->e_shnum; i++)
	{
		if (shdr[i].sh_type == SHT_SYMTAB)
		{
			symtab = &shdr[i];
			break;
		}
	}

	if (!symtab)
	{
		fprintf(stderr, "no symbols\n");
		return (1);
	}

	strtab_hdr = &shdr[symtab->sh_link];
	syms = (Elf32_Sym *)((char *)nm->data + symtab->sh_offset);
	strtab = (char *)nm->data + strtab_hdr->sh_offset;
	sym_count = symtab->sh_size / sizeof(Elf32_Sym);

	/* Print symbols */
	for (i = 1; i < sym_count; i++)
	{
		char		*name;
		char		type;
		Elf32_Shdr	*sec;

		name = strtab + syms[i].st_name;
		if (!name[0])
			continue;

		sec = NULL;
		if (syms[i].st_shndx < ehdr->e_shnum)
			sec = &shdr[syms[i].st_shndx];

		type = get_symbol_type_32(&syms[i], sec);

		if (syms[i].st_value != 0 || type == 'T' || type == 't')
			printf("%08x %c %s\n", syms[i].st_value, type, name);
		else
			printf("%10s %c %s\n", "", type, name);
	}
	return (0);
}

static int	process_file(const char *filename, int multiple)
{
	int			fd;
	struct stat	st;
	t_nm		nm;
	unsigned char	*ident;

	if (multiple)
		printf("\n%s:\n", filename);

	fd = open(filename, O_RDONLY);
	if (fd < 0)
	{
		perror(filename);
		return (1);
	}

	if (fstat(fd, &st) < 0)
	{
		perror("fstat");
		close(fd);
		return (1);
	}

	nm.size = st.st_size;
	nm.data = mmap(NULL, nm.size, PROT_READ, MAP_PRIVATE, fd, 0);
	close(fd);

	if (nm.data == MAP_FAILED)
	{
		perror("mmap");
		return (1);
	}

	/* Check ELF magic */
	ident = (unsigned char *)nm.data;
	if (nm.size < EI_NIDENT || ident[0] != 0x7f ||
		ident[1] != 'E' || ident[2] != 'L' || ident[3] != 'F')
	{
		fprintf(stderr, "%s: not an ELF file\n", filename);
		munmap(nm.data, nm.size);
		return (1);
	}

	nm.is_64bit = (ident[EI_CLASS] == ELFCLASS64);

	int ret;
	if (nm.is_64bit)
		ret = process_64(&nm);
	else
		ret = process_32(&nm);

	munmap(nm.data, nm.size);
	return (ret);
}

int	main(int argc, char **argv)
{
	int	i;
	int	ret;
	int	multiple;

	if (argc < 2)
	{
		printf("Usage: %s <file> [file...]\n", argv[0]);
		printf("Display symbol table of ELF files\n");
		return (1);
	}

	ret = 0;
	multiple = (argc > 2);

	for (i = 1; i < argc; i++)
	{
		if (process_file(argv[i], multiple) != 0)
			ret = 1;
	}

	return (ret);
}
