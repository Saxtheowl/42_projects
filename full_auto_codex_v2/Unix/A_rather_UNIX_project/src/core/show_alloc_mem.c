#include "malloc_internal.h"

#include <stdint.h>

static void	print_hex(uintptr_t value)
{
	char	buffer[17];
	int	 index;

	index = 16;
	buffer[index] = '\0';
	while (index > 0)
	{
		index--;
		buffer[index] = "0123456789abcdef"[value & 0xF];
		value >>= 4;
	}
	ft_putstr_fd(buffer, 1);
}

static void	print_address(uintptr_t addr)
{
	ft_putstr_fd("0x", 1);
	print_hex(addr);
}

static size_t	print_zone(const char *label, t_zone *zone)
{
	size_t	total;
	t_zone	*current_zone;
	int	 printed_header;

	total = 0;
	current_zone = zone;
	printed_header = 0;
	while (current_zone)
	{
		t_block	*block;

		if (!printed_header)
		{
			ft_putstr_fd(label, 1);
			ft_putstr_fd(" : ", 1);
			print_address((uintptr_t)current_zone);
			ft_putstr_fd("\n", 1);
			printed_header = 1;
		}
		block = current_zone->first;
		while (block)
		{
			if (!block->free)
			{
				uintptr_t	start;
				uintptr_t	end;

				start = (uintptr_t)(block + 1);
				end = start + block->size;
				print_address(start);
				ft_putstr_fd(" - ", 1);
				print_address(end);
				ft_putstr_fd(" : ", 1);
				ft_putnbr_fd(block->size, 1);
				ft_putstr_fd(" bytes\n", 1);
				total += block->size;
			}
			block = block->next;
		}
		current_zone = current_zone->next;
	}
	return (total);
}

void	show_alloc_zones(void)
{
	size_t	total;

	total = 0;
	total += print_zone("TINY", g_malloc_state.tiny);
	total += print_zone("SMALL", g_malloc_state.small);
	total += print_zone("LARGE", g_malloc_state.large);
	ft_putstr_fd("Total : ", 1);
	ft_putnbr_fd(total, 1);
	ft_putstr_fd(" bytes\n", 1);
}
