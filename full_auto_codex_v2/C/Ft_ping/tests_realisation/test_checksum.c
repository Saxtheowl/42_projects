#include "ft_ping.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

static void	test_rfc_1071_sample(void)
{
	const unsigned char payload[] = {
		0x00, 0x01, 0xF2, 0x03, 0xF4, 0x05, 0xF6, 0x07,
		0xF8, 0x09, 0xFA, 0x0B, 0xFC, 0x0D, 0xFE, 0x0F};
	unsigned short     result;

	result = ft_icmp_checksum(payload, sizeof(payload));
	/* Host-endian representation of RFC 1071 sample (network 0x37B9) */
	assert(result == 0xB937);
}

static void	test_icmp_echo_frame(void)
{
	unsigned char frame[sizeof(struct icmphdr) + FT_PING_DEFAULT_PAYLOAD_SIZE];
	unsigned short result;

	memset(frame, 0, sizeof(frame));
	frame[0] = ICMP_ECHO;         /* type */
	frame[1] = 0;                 /* code */
	/* checksum left zeroed for computation */
	frame[4] = 0x12;              /* identifier high */
	frame[5] = 0x34;              /* identifier low */
	frame[6] = 0x00;              /* seq high */
	frame[7] = 0x01;              /* seq low */
	for (size_t i = 0; i < FT_PING_DEFAULT_PAYLOAD_SIZE; ++i)
		frame[sizeof(struct icmphdr) + i] = (unsigned char)i;
	result = ft_icmp_checksum(frame, sizeof(frame));
	/* Host-endian representation for network checksum 0xEEB7 */
	assert(result == 0xB7EE);
}

int	main(void)
{
	test_rfc_1071_sample();
	test_icmp_echo_frame();
	puts("checksum tests: OK");
	return (0);
}
