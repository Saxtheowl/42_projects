/* ************************************************************************** */
/*                                                                            */
/*   woody_woodpacker - ELF binary packer                                     */
/*   Packs ELF binaries with simple encryption                                */
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

#define WOODY_MAGIC "WOODY"
#define XOR_KEY 0x42

typedef struct s_woody
{
	void		*data;
	size_t		size;
	Elf64_Ehdr	*ehdr;
	Elf64_Phdr	*phdr;
	Elf64_Shdr	*shdr;
	void		*text_section;
	size_t		text_size;
	size_t		text_offset;
}	t_woody;

static int	load_file(const char *filename, t_woody *woody)
{
	int			fd;
	struct stat	st;

	fd = open(filename, O_RDONLY);
	if (fd < 0)
	{
		perror("open");
		return (-1);
	}

	if (fstat(fd, &st) < 0)
	{
		perror("fstat");
		close(fd);
		return (-1);
	}

	woody->size = st.st_size;
	woody->data = mmap(NULL, woody->size, PROT_READ | PROT_WRITE,
					   MAP_PRIVATE, fd, 0);
	close(fd);

	if (woody->data == MAP_FAILED)
	{
		perror("mmap");
		return (-1);
	}

	return (0);
}

static int	validate_elf(t_woody *woody)
{
	unsigned char	*ident;

	if (woody->size < sizeof(Elf64_Ehdr))
	{
		fprintf(stderr, "File too small for ELF header\n");
		return (-1);
	}

	ident = (unsigned char *)woody->data;
	if (ident[0] != 0x7f || ident[1] != 'E' ||
		ident[2] != 'L' || ident[3] != 'F')
	{
		fprintf(stderr, "Not an ELF file\n");
		return (-1);
	}

	if (ident[EI_CLASS] != ELFCLASS64)
	{
		fprintf(stderr, "Only 64-bit ELF supported\n");
		return (-1);
	}

	woody->ehdr = (Elf64_Ehdr *)woody->data;
	woody->phdr = (Elf64_Phdr *)((char *)woody->data + woody->ehdr->e_phoff);
	woody->shdr = (Elf64_Shdr *)((char *)woody->data + woody->ehdr->e_shoff);

	if (woody->ehdr->e_type != ET_EXEC && woody->ehdr->e_type != ET_DYN)
	{
		fprintf(stderr, "Only executable ELF supported\n");
		return (-1);
	}

	return (0);
}

static int	find_text_section(t_woody *woody)
{
	char	*shstrtab;
	size_t	i;

	if (woody->ehdr->e_shstrndx >= woody->ehdr->e_shnum)
		return (-1);

	shstrtab = (char *)woody->data + woody->shdr[woody->ehdr->e_shstrndx].sh_offset;

	for (i = 0; i < woody->ehdr->e_shnum; i++)
	{
		if (strcmp(shstrtab + woody->shdr[i].sh_name, ".text") == 0)
		{
			woody->text_section = (char *)woody->data + woody->shdr[i].sh_offset;
			woody->text_size = woody->shdr[i].sh_size;
			woody->text_offset = woody->shdr[i].sh_offset;
			return (0);
		}
	}

	fprintf(stderr, "No .text section found\n");
	return (-1);
}

static void	xor_encrypt(void *data, size_t size, unsigned char key)
{
	unsigned char	*bytes;
	size_t			i;

	bytes = (unsigned char *)data;
	for (i = 0; i < size; i++)
		bytes[i] ^= key;
}

static int	save_packed(const char *filename, t_woody *woody)
{
	int		fd;
	char	output[256];

	(void)filename;
	snprintf(output, sizeof(output), "woody");

	fd = open(output, O_WRONLY | O_CREAT | O_TRUNC, 0755);
	if (fd < 0)
	{
		perror("open output");
		return (-1);
	}

	if (write(fd, woody->data, woody->size) != (ssize_t)woody->size)
	{
		perror("write");
		close(fd);
		return (-1);
	}

	close(fd);
	printf("Packed binary saved as: %s\n", output);
	return (0);
}

static void	print_info(t_woody *woody)
{
	printf("ELF Header:\n");
	printf("  Type: %s\n",
		   woody->ehdr->e_type == ET_EXEC ? "EXEC" : "DYN");
	printf("  Entry point: 0x%lx\n", woody->ehdr->e_entry);
	printf("  Program headers: %d\n", woody->ehdr->e_phnum);
	printf("  Section headers: %d\n", woody->ehdr->e_shnum);
	printf("\n.text section:\n");
	printf("  Offset: 0x%lx\n", woody->text_offset);
	printf("  Size: %zu bytes\n", woody->text_size);
}

int	main(int argc, char **argv)
{
	t_woody	woody;

	if (argc != 2)
	{
		printf("Usage: %s <elf_binary>\n", argv[0]);
		printf("\nPacks an ELF binary with XOR encryption on .text section.\n");
		printf("Output is saved as 'woody'.\n");
		return (1);
	}

	memset(&woody, 0, sizeof(woody));

	printf("woody_woodpacker - ELF Packer\n");
	printf("=============================\n\n");

	/* Load file */
	printf("Loading %s...\n", argv[1]);
	if (load_file(argv[1], &woody) < 0)
		return (1);

	/* Validate ELF */
	printf("Validating ELF format...\n");
	if (validate_elf(&woody) < 0)
	{
		munmap(woody.data, woody.size);
		return (1);
	}

	/* Find .text section */
	printf("Finding .text section...\n");
	if (find_text_section(&woody) < 0)
	{
		munmap(woody.data, woody.size);
		return (1);
	}

	print_info(&woody);

	/* Encrypt .text section */
	printf("\nEncrypting .text section with XOR (key: 0x%02X)...\n", XOR_KEY);
	xor_encrypt(woody.text_section, woody.text_size, XOR_KEY);

	/* Save packed binary */
	printf("Saving packed binary...\n");
	if (save_packed(argv[1], &woody) < 0)
	{
		munmap(woody.data, woody.size);
		return (1);
	}

	printf("\nDone! Note: The packed binary needs a decryption stub to run.\n");
	printf("This is a simplified packer for educational purposes.\n");

	munmap(woody.data, woody.size);
	return (0);
}
