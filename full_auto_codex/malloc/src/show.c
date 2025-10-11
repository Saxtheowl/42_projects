#include "malloc_internal.h"

#include <unistd.h>

static void show_char(char c)
{
	write(1, &c, 1);
}

void show_print_str(const char *str)
{
	while (str && *str)
	{
		write(1, str, 1);
		++str;
	}
}

void show_print_hex(unsigned long value)
{
	char	buffer[sizeof(unsigned long) * 2 + 1];
	const char	*base = "0123456789ABCDEF";
	size_t	index;

	index = 0;
	if (value == 0)
	{
		show_print_str("0");
		return ;
	}
	while (value > 0 && index < sizeof(buffer) - 1)
	{
		buffer[index++] = base[value % 16];
		value /= 16;
	}
	while (index-- > 0)
		show_char(buffer[index]);
}

void show_print_size(size_t value)
{
	char	buffer[32];
	size_t	index;

	if (value == 0)
	{
		show_char('0');
		return ;
	}
	index = 0;
	while (value > 0 && index < sizeof(buffer))
	{
		buffer[index++] = '0' + (value % 10);
		value /= 10;
	}
	while (index-- > 0)
		show_char(buffer[index]);
}

static void show_block(t_block *block, size_t *total)
{
	unsigned long start;
	unsigned long end;

	start = (unsigned long)(block + 1);
	end = start + block->size;
	show_print_str("0x");
	show_print_hex(start);
	show_print_str(" - 0x");
	show_print_hex(end);
	show_print_str(" : ");
	show_print_size(block->size);
	show_print_str(" bytes\n");
	if (total)
		*total += block->size;
}

static void show_zone(const char *label, t_zone *zone, size_t *total)
{
	t_block	*block;

	if (!zone)
		return ;
	while (zone)
	{
		show_print_str(label);
		show_print_str(" : 0x");
		show_print_hex((unsigned long)zone);
		show_print_str("\n");
		block = zone->blocks;
		while (block)
		{
			if (!block->free)
				show_block(block, total);
			block = block->next;
		}
		zone = zone->next;
	}
}

static void show_large(t_large *large, size_t *total)
{
	while (large)
	{
		show_print_str("LARGE : 0x");
		show_print_hex((unsigned long)large);
		show_print_str("\n");
		show_print_str("0x");
		show_print_hex((unsigned long)(large + 1));
		show_print_str(" - 0x");
		show_print_hex((unsigned long)(large + 1) + large->size);
		show_print_str(" : ");
		show_print_size(large->size);
		show_print_str(" bytes\n");
		if (total)
			*total += large->size;
		large = large->next;
	}
}

void show_alloc_mem(void)
{
	size_t total;

	total = 0;
	pthread_mutex_lock(&g_state.lock);
	show_zone("TINY", g_state.tiny, &total);
	show_zone("SMALL", g_state.small, &total);
	show_large(g_state.large, &total);
	show_print_str("Total : ");
	show_print_size(total);
	show_print_str(" bytes\n");
	pthread_mutex_unlock(&g_state.lock);
}
