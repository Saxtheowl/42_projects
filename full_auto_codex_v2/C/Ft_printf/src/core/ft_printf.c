#include "ft_printf.h"

static void	parse_format(t_format *format)
{
	char	c;

	while (format->fmt[format->pos] != '\0' && !format->buffer.error)
	{
		c = format->fmt[format->pos];
		if (c == '%')
		{
			format->pos++;
			if (format->fmt[format->pos] == '\0')
				break ;
			handle_conversion(format);
		}
		else
			buffer_write_char(&format->buffer, c);
		format->pos++;
	}
}

int	ft_vprintf(const char *fmt, va_list ap)
{
	t_format	format;

	if (fmt == NULL)
		return (-1);
	format.fmt = fmt;
	format.pos = 0;
	buffer_init(&format.buffer, 1);
	va_copy(format.args, ap);
	parse_format(&format);
	va_end(format.args);
	buffer_flush(&format.buffer);
	if (format.buffer.error)
		return (-1);
	return ((int)format.buffer.total);
}

int	ft_printf(const char *fmt, ...)
{
	va_list ap;
	int		result;

	va_start(ap, fmt);
	result = ft_vprintf(fmt, ap);
	va_end(ap);
	return (result);
}
