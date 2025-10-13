#ifndef MACHO_H
#define MACHO_H

#include <stdint.h>
#include <stddef.h>

#include "common.h"

#define MH_MAGIC_64 0xfeedfacf
#define LC_SEGMENT_64 0x19
#define LC_SYMTAB 0x2

#define N_STAB 0xe0u
#define N_PEXT 0x10u
#define N_TYPE 0x0eu
#define N_EXT 0x01u

#define N_UNDF 0x00u
#define N_ABS 0x02u
#define N_SECT 0x0eu
#define N_PBUD 0x0cu
#define N_INDR 0x0au

typedef struct mach_header_64
{
	uint32_t	magic;
	int32_t		cputype;
	int32_t		cpusubtype;
	uint32_t	filetype;
	uint32_t	ncmds;
	uint32_t	sizeofcmds;
	uint32_t	flags;
	uint32_t	reserved;
}				t_mach_header_64;

typedef struct load_command
{
	uint32_t	cmd;
	uint32_t	cmdsize;
}				t_load_command;

typedef struct symtab_command
{
	uint32_t	cmd;
	uint32_t	cmdsize;
	uint32_t	symoff;
	uint32_t	nsyms;
	uint32_t	stroff;
	uint32_t	strsize;
}				t_symtab_command;

typedef struct segment_command_64
{
	uint32_t	cmd;
	uint32_t	cmdsize;
	char		segname[16];
	uint64_t	vmaddr;
	uint64_t	vmsize;
	uint64_t	fileoff;
	uint64_t	filesize;
	uint32_t	maxprot;
	uint32_t	initprot;
	uint32_t	nsects;
	uint32_t	flags;
}				t_segment_command_64;

typedef struct section_64
{
	char		sectname[16];
	char		segname[16];
	uint64_t	addr;
	uint64_t	size;
	uint32_t	offset;
	uint32_t	align;
	uint32_t	reloff;
	uint32_t	nreloc;
	uint32_t	flags;
	uint32_t	reserved1;
	uint32_t	reserved2;
	uint32_t	reserved3;
}				t_section_64;

typedef struct nlist_64
{
	uint32_t	n_strx;
	uint8_t		n_type;
	uint8_t		n_sect;
	uint16_t	n_desc;
	uint64_t	n_value;
}				t_nlist_64;

typedef struct s_section_info
{
	char		segname[17];
	char		sectname[17];
	uint64_t	addr;
	uint64_t	size;
	uint32_t	offset;
}				t_section_info;

typedef struct s_macho_file
{
	const t_mapped_file		*mapped;
	const t_mach_header_64	*header;
	const t_symtab_command	*symtab;
	t_section_info			*sections;
	uint32_t				section_count;
}				t_macho_file;

int					macho_load(const t_mapped_file *mapped, t_macho_file *out);
void				macho_unload(t_macho_file *file);
const t_section_info	*macho_find_section(const t_macho_file *file,
						const char *segname, const char *sectname);

#endif
