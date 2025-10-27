#include "ft_printf.h"

void	convert_char(t_format *format)
{
	int	c;

	c = va_arg(format->args, int);
	buffer_write_char(&format->buffer, (char)c);
}
