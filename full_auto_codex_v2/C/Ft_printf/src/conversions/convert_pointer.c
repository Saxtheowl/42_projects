#include "ft_printf.h"

void	convert_pointer(t_format *format)
{
	unsigned long	value;

	value = (unsigned long)va_arg(format->args, void *);
	buffer_write(&format->buffer, "0x", 2);
	if (value == 0)
		buffer_write_char(&format->buffer, '0');
	else
		write_hex(&format->buffer, value, 0);
}
