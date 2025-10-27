#include "ft_printf.h"

void	convert_signed(t_format *format)
{
	int	value;

	value = va_arg(format->args, int);
	write_signed(&format->buffer, (long)value);
}
