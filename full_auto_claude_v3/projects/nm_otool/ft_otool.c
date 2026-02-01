/* ************************************************************************** */
/*                                                                            */
/*   ft_otool - Display object file sections                                  */
/*   Similar to objdump -s for ELF files                                      */
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
#include <ctype.h>

typedef struct s_otool
{
	void	*data;
	size_t	size;
	int		is_64bit;
}	t_otool;

static void	print_hex_dump(void *data, size_t offset, size_t size, size_t addr)
{
	unsigned char	*bytes;
	size_t			i;
	size_t			j;

	bytes = (unsigned char *)data + offset;

	for (i = 0; i < size; i += 16)
	{
		/* Address */
		printf(" %08lx", (unsigned long)(addr + i));

		/* Hex bytes */
		for (j = 0; j < 16 && i + j < size; j++)
		{
			if (j % 4 == 0)
				printf(" ");
			printf("%02x", bytes[i + j]);
		}

		/* Padding for incomplete lines */
		for (; j < 16; j++)
		{
			if (j % 4 == 0)
				printf(" ");
			printf("  ");
		}

		/* ASCII */
		printf("  ");
		for (j = 0; j < 16 && i + j < size; j++)
		{
			char c = bytes[i + j];
			printf("%c", isprint(c) ? c : '.');
		}
		printf("\n");
	}
}

static int	process_64(t_otool *ot, int show_text)
{
	Elf64_Ehdr	*ehdr;
	Elf64_Shdr	*shdr;
	char		*shstrtab;
	size_t		i;

	ehdr = (Elf64_Ehdr *)ot->data;
	shdr = (Elf64_Shdr *)((char *)ot->data + ehdr->e_shoff);

	/* Get section header string table */
	if (ehdr->e_shstrndx >= ehdr->e_shnum)
		return (1);

	shstrtab = (char *)ot->data + shdr[ehdr->e_shstrndx].sh_offset;

	/* Print sections */
	for (i = 0; i < ehdr->e_shnum; i++)
	{
		char	*name;

		name = shstrtab + shdr[i].sh_name;

		if (show_text && strcmp(name, ".text") != 0)
			continue;

		if (shdr[i].sh_size == 0)
			continue;

		/* Skip non-data sections */
		if (shdr[i].sh_type != SHT_PROGBITS &&
			shdr[i].sh_type != SHT_NOBITS)
			continue;

		printf("Contents of section %s:\n", name);
		if (shdr[i].sh_type != SHT_NOBITS)
		{
			print_hex_dump(ot->data, shdr[i].sh_offset,
						   shdr[i].sh_size, shdr[i].sh_addr);
		}
	}
	return (0);
}

static int	process_32(t_otool *ot, int show_text)
{
	Elf32_Ehdr	*ehdr;
	Elf32_Shdr	*shdr;
	char		*shstrtab;
	size_t		i;

	ehdr = (Elf32_Ehdr *)ot->data;
	shdr = (Elf32_Shdr *)((char *)ot->data + ehdr->e_shoff);

	if (ehdr->e_shstrndx >= ehdr->e_shnum)
		return (1);

	shstrtab = (char *)ot->data + shdr[ehdr->e_shstrndx].sh_offset;

	for (i = 0; i < ehdr->e_shnum; i++)
	{
		char	*name;

		name = shstrtab + shdr[i].sh_name;

		if (show_text && strcmp(name, ".text") != 0)
			continue;

		if (shdr[i].sh_size == 0)
			continue;

		if (shdr[i].sh_type != SHT_PROGBITS &&
			shdr[i].sh_type != SHT_NOBITS)
			continue;

		printf("Contents of section %s:\n", name);
		if (shdr[i].sh_type != SHT_NOBITS)
		{
			print_hex_dump(ot->data, shdr[i].sh_offset,
						   shdr[i].sh_size, shdr[i].sh_addr);
		}
	}
	return (0);
}

static void	print_header_64(t_otool *ot)
{
	Elf64_Ehdr	*ehdr;

	ehdr = (Elf64_Ehdr *)ot->data;

	printf("ELF Header:\n");
	printf("  Class:                             ELF64\n");
	printf("  Data:                              %s\n",
		   ehdr->e_ident[EI_DATA] == ELFDATA2LSB ? "Little endian" : "Big endian");
	printf("  Type:                              ");
	switch (ehdr->e_type)
	{
		case ET_EXEC: printf("EXEC (Executable)\n"); break;
		case ET_DYN: printf("DYN (Shared object)\n"); break;
		case ET_REL: printf("REL (Relocatable)\n"); break;
		default: printf("Unknown (%d)\n", ehdr->e_type);
	}
	printf("  Machine:                           ");
	switch (ehdr->e_machine)
	{
		case EM_X86_64: printf("x86-64\n"); break;
		case EM_386: printf("i386\n"); break;
		case EM_ARM: printf("ARM\n"); break;
		case EM_AARCH64: printf("AArch64\n"); break;
		default: printf("Unknown (%d)\n", ehdr->e_machine);
	}
	printf("  Entry point:                       0x%lx\n", ehdr->e_entry);
	printf("  Section headers:                   %d\n", ehdr->e_shnum);
	printf("  Program headers:                   %d\n", ehdr->e_phnum);
}

static int	process_file(const char *filename, int show_text, int show_header, int multiple)
{
	int			fd;
	struct stat	st;
	t_otool		ot;
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

	ot.size = st.st_size;
	ot.data = mmap(NULL, ot.size, PROT_READ, MAP_PRIVATE, fd, 0);
	close(fd);

	if (ot.data == MAP_FAILED)
	{
		perror("mmap");
		return (1);
	}

	ident = (unsigned char *)ot.data;
	if (ot.size < EI_NIDENT || ident[0] != 0x7f ||
		ident[1] != 'E' || ident[2] != 'L' || ident[3] != 'F')
	{
		fprintf(stderr, "%s: not an ELF file\n", filename);
		munmap(ot.data, ot.size);
		return (1);
	}

	ot.is_64bit = (ident[EI_CLASS] == ELFCLASS64);

	int ret = 0;
	if (show_header && ot.is_64bit)
		print_header_64(&ot);
	else if (ot.is_64bit)
		ret = process_64(&ot, show_text);
	else
		ret = process_32(&ot, show_text);

	munmap(ot.data, ot.size);
	return (ret);
}

int	main(int argc, char **argv)
{
	int	i;
	int	ret;
	int	show_text;
	int	show_header;
	int	multiple;
	int	first_file;

	if (argc < 2)
	{
		printf("Usage: %s [-t] [-h] <file> [file...]\n", argv[0]);
		printf("  -t  Show only .text section\n");
		printf("  -h  Show ELF header\n");
		return (1);
	}

	show_text = 0;
	show_header = 0;
	first_file = 1;

	for (i = 1; i < argc; i++)
	{
		if (argv[i][0] == '-')
		{
			if (strcmp(argv[i], "-t") == 0)
				show_text = 1;
			else if (strcmp(argv[i], "-h") == 0)
				show_header = 1;
			first_file++;
		}
		else
			break;
	}

	ret = 0;
	multiple = (argc - first_file > 1);

	for (i = first_file; i < argc; i++)
	{
		if (process_file(argv[i], show_text, show_header, multiple) != 0)
			ret = 1;
	}

	return (ret);
}
