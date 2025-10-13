#include "macho.h"

#include <stdlib.h>

#include "libft.h"

static int	check_load_command_range(const t_mapped_file *file, size_t offset, uint32_t size)
{
	if (size < sizeof(t_load_command))
		return (-1);
	return (ensure_range(file, offset, size));
}

static void	store_section_info(t_section_info *dst, const t_section_64 *src)
{
	ft_bzero(dst->segname, sizeof(dst->segname));
	ft_bzero(dst->sectname, sizeof(dst->sectname));
	ft_memcpy(dst->segname, src->segname, 16);
	ft_memcpy(dst->sectname, src->sectname, 16);
	dst->segname[16] = '\0';
	dst->sectname[16] = '\0';
	dst->addr = src->addr;
	dst->size = src->size;
	dst->offset = src->offset;
}

static int	count_sections(const t_mapped_file *file, const t_mach_header_64 *header)
{
	size_t		offset;
	uint32_t	index;
	int		count;

	offset = sizeof(t_mach_header_64);
	count = 0;
	index = 0;
	while (index < header->ncmds)
	{
		const t_load_command	*cmd;

		if (ensure_range(file, offset, sizeof(t_load_command)) != 0)
			return (-1);
		cmd = (const t_load_command *)(file->data + offset);
		if (check_load_command_range(file, offset, cmd->cmdsize) != 0)
			return (-1);
		if (cmd->cmdsize == 0)
			return (-1);
		if (cmd->cmd == LC_SEGMENT_64)
		{
			const t_segment_command_64	*segment;

			segment = (const t_segment_command_64 *)(file->data + offset);
			if (cmd->cmdsize < sizeof(t_segment_command_64))
				return (-1);
			if (segment->nsects > 0)
			{
				if ((size_t)(segment->nsects) > ((size_t)UINT32_MAX - (size_t)count))
					return (-1);
				count += segment->nsects;
			}
		}
		offset += cmd->cmdsize;
		index++;
	}
	return (count);
}

static int	populate_sections(const t_mapped_file *file, const t_mach_header_64 *header,
				 t_section_info *sections, const t_symtab_command **out_symtab)
{
	size_t		offset;
	uint32_t	cmd_index;
	uint32_t	section_index;

	section_index = 0;
	offset = sizeof(t_mach_header_64);
	cmd_index = 0;
	*out_symtab = NULL;
	while (cmd_index < header->ncmds)
	{
		const t_load_command *cmd;

		cmd = (const t_load_command *)(file->data + offset);
		if (cmd->cmdsize == 0)
			return (-1);
		if (cmd->cmd == LC_SEGMENT_64)
		{
			const t_segment_command_64	*segment;
			const t_section_64		*section;
			uint32_t				 i;

			segment = (const t_segment_command_64 *)(file->data + offset);
			section = (const t_section_64 *)((const uint8_t *)segment
				+ sizeof(t_segment_command_64));
			i = 0;
			while (i < segment->nsects)
			{
				if (ensure_range(file,
					(size_t)((const uint8_t *)section - file->data), sizeof(t_section_64)) != 0)
					return (-1);
				store_section_info(&sections[section_index], section);
				section_index++;
				section++;
				i++;
			}
		}
		else if (cmd->cmd == LC_SYMTAB)
			*out_symtab = (const t_symtab_command *)(file->data + offset);
		offset += cmd->cmdsize;
		cmd_index++;
	}
	return (0);
}

int	macho_load(const t_mapped_file *mapped, t_macho_file *out)
{
	int	section_total;

	ft_bzero(out, sizeof(*out));
	out->mapped = mapped;
	if (mapped->size < sizeof(t_mach_header_64))
		return (-1);
	out->header = (const t_mach_header_64 *)mapped->data;
	if (out->header->magic != MH_MAGIC_64)
		return (-1);
	if (out->header->ncmds == 0)
		return (-1);
	section_total = count_sections(mapped, out->header);
	if (section_total < 0)
		return (-1);
	if (section_total > 0)
	{
		out->sections = ft_calloc(section_total, sizeof(t_section_info));
		if (out->sections == NULL)
			return (-1);
	}
	if (populate_sections(mapped, out->header, out->sections, &out->symtab) != 0)
	{
		macho_unload(out);
		return (-1);
	}
	out->section_count = (uint32_t)section_total;
	if (out->symtab == NULL)
	{
		macho_unload(out);
		return (-1);
	}
	if (out->symtab->symoff == 0 || out->symtab->stroff == 0)
	{
		macho_unload(out);
		return (-1);
	}
	if (ensure_range(mapped, out->symtab->symoff,
		(size_t)out->symtab->nsyms * sizeof(t_nlist_64)) != 0)
	{
		macho_unload(out);
		return (-1);
	}
	if (ensure_range(mapped, out->symtab->stroff, out->symtab->strsize) != 0)
	{
		macho_unload(out);
		return (-1);
	}
	return (0);
}

void	macho_unload(t_macho_file *file)
{
	if (file->sections != NULL)
		free(file->sections);
	file->sections = NULL;
	file->section_count = 0;
	file->symtab = NULL;
	file->header = NULL;
	file->mapped = NULL;
}

const t_section_info	*macho_find_section(const t_macho_file *file,
		const char *segname, const char *sectname)
{
	uint32_t	index;

	index = 0;
	while (index < file->section_count)
	{
		const t_section_info	*info;

		info = &file->sections[index];
		if (ft_strncmp(info->segname, segname, 16) == 0
			&& ft_strncmp(info->sectname, sectname, 16) == 0)
			return (info);
		index++;
	}
	return (NULL);
}
