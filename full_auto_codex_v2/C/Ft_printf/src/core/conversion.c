#include "ft_printf.h"

static void	skip_unknown(t_format *format)
{
	char	c;

	c = format->fmt[format->pos];
	if (c != '\0')
		buffer_write_char(&format->buffer, c);
}

void	handle_conversion(t_format *format)
{
	char	specifier;

	specifier = format->fmt[format->pos];
	if (specifier == 'c')
		convert_char(format);
	else if (specifier == 's')
		convert_string(format);
	else if (specifier == 'd' || specifier == 'i')
		convert_signed(format);
	else if (specifier == 'u')
		convert_unsigned(format);
	else if (specifier == 'x')
		convert_hex_lower(format);
	else if (specifier == 'X')
		convert_hex_upper(format);
	else if (specifier == 'p')
		convert_pointer(format);
	else if (specifier == '%')
		convert_percent(format);
	else
		skip_unknown(format);
}
