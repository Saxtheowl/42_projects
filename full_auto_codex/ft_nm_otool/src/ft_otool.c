#include "ft_nm_otool.h"

#include <stdio.h>
#include <stdint.h>

static const Elf64_Shdr *find_text_section(const t_mapped_file *file, const Elf64_Ehdr *ehdr)
{
	const Elf64_Shdr *sections;

	sections = (const Elf64_Shdr *)((const char *)file->addr + ehdr->e_shoff);
	for (size_t i = 0; i < ehdr->e_shnum; ++i)
	{
		if (sections[i].sh_type == SHT_PROGBITS && (sections[i].sh_flags & SHF_EXECINSTR))
			return &sections[i];
	}
	return NULL;
}

static void print_bytes(uint64_t address, const unsigned char *data, size_t size)
{
	for (size_t i = 0; i < size; i += 16)
	{
		printf("%016lx\t", address + i);
		for (size_t j = 0; j < 16 && i + j < size; ++j)
			printf("%02x ", data[i + j]);
		printf("\n");
	}
}

int print_otool(const char *path)
{
	t_mapped_file file;
	Elf64_Ehdr *ehdr;
	const Elf64_Shdr *text;

	if (map_file(path, &file) != 0)
	{
		fprintf(stderr, "ft_otool: %s: cannot open file\n", path);
		return 1;
	}
	if (validate_elf64(&file, &ehdr) != 0)
	{
		fprintf(stderr, "ft_otool: %s: unsupported file\n", path);
		unmap_file(&file);
		return 1;
	}
	text = find_text_section(&file, ehdr);
	if (!text || text->sh_offset + text->sh_size > file.size)
	{
		fprintf(stderr, "ft_otool: %s: text section not found\n", path);
		unmap_file(&file);
		return 1;
	}
	printf("%s:\n", path);
	printf("Contents of (__TEXT,__text) section\n");
	print_bytes(text->sh_addr, (const unsigned char *)file.addr + text->sh_offset, text->sh_size);
	unmap_file(&file);
	return 0;
}
