#include "ft_printf.h"

void	convert_hex_lower(t_format *format)
{
	unsigned int	value;

	value = va_arg(format->args, unsigned int);
	write_hex(&format->buffer, (unsigned long)value, 0);
}

void	convert_hex_upper(t_format *format)
{
	unsigned int	value;

	value = va_arg(format->args, unsigned int);
	write_hex(&format->buffer, (unsigned long)value, 1);
}
