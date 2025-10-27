#include "ft_ping.h"

#include <stdint.h>

unsigned short	ft_icmp_checksum(const void *data, size_t len)
{
	const uint16_t	*words;
	uint32_t		sum;

	words = (const uint16_t *)data;
	sum = 0;
	while (len > 1)
	{
		sum += *words;
		words++;
		len -= 2;
	}
	if (len > 0)
		sum += *(const uint8_t *)words;
	while (sum >> 16)
		sum = (sum & 0xFFFF) + (sum >> 16);
	return ((~sum) & 0xFFFF);
}
