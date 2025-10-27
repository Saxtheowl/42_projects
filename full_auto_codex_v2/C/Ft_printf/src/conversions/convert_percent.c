#include "ft_printf.h"

void	convert_percent(t_format *format)
{
	buffer_write_char(&format->buffer, '%');
}
