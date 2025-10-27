#include "ft_printf.h"

void	convert_string(t_format *format)
{
	const char	*str;

	str = va_arg(format->args, const char *);
	write_string(&format->buffer, str);
}
