#include "ft_printf.h"

static void	write_digits(t_buffer *buffer, unsigned long value)
{
	if (value >= 10)
		write_digits(buffer, value / 10);
	buffer_write_char(buffer, (char)('0' + (value % 10)));
}

void	write_signed(t_buffer *buffer, long value)
{
	unsigned long	magnitude;

	if (value < 0)
	{
		buffer_write_char(buffer, '-');
		magnitude = (unsigned long)(-(value + 1));
		magnitude += 1;
		write_digits(buffer, magnitude);
	}
	else
	{
		magnitude = (unsigned long)value;
		write_digits(buffer, magnitude);
	}
}

void	write_unsigned(t_buffer *buffer, unsigned long value)
{
	write_digits(buffer, value);
}

static void	write_hex_digits(t_buffer *buffer, unsigned long value,
		const char *alphabet)
{
	if (value >= 16)
		write_hex_digits(buffer, value / 16, alphabet);
	buffer_write_char(buffer, alphabet[value % 16]);
}

void	write_hex(t_buffer *buffer, unsigned long value, int uppercase)
{
	const char	*alphabet;

	alphabet = "0123456789abcdef";
	if (uppercase)
		alphabet = "0123456789ABCDEF";
	write_hex_digits(buffer, value, alphabet);
}
