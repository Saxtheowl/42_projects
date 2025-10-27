#include "ft_printf.h"

void	convert_unsigned(t_format *format)
{
	unsigned int	value;

	value = va_arg(format->args, unsigned int);
	write_unsigned(&format->buffer, (unsigned long)value);
}
