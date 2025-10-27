#ifndef FT_PRINTF_H
# define FT_PRINTF_H

# include <stdarg.h>
# include <stddef.h>
# include <unistd.h>

typedef struct s_buffer
{
	char	data[1024];
	size_t	index;
	size_t	total;
	int		error;
	int		fd;
}	t_buffer;

typedef struct s_format
{
	const char	*fmt;
	size_t		pos;
	va_list		args;
	t_buffer	buffer;
}	t_format;

int		ft_printf(const char *fmt, ...);
int		ft_vprintf(const char *fmt, va_list ap);

/* Buffer helpers */
void	buffer_init(t_buffer *buffer, int fd);
void	buffer_write_char(t_buffer *buffer, char c);
void	buffer_write(t_buffer *buffer, const char *data, size_t len);
void	buffer_flush(t_buffer *buffer);

/* Core parsing */
void	handle_conversion(t_format *format);

/* Conversions */
void	convert_char(t_format *format);
void	convert_string(t_format *format);
void	convert_percent(t_format *format);
void	convert_signed(t_format *format);
void	convert_unsigned(t_format *format);
void	convert_hex_lower(t_format *format);
void	convert_hex_upper(t_format *format);
void	convert_pointer(t_format *format);

/* Utilities */
size_t	ft_strlen(const char *s);
void	write_string(t_buffer *buffer, const char *s);
void	write_signed(t_buffer *buffer, long value);
void	write_unsigned(t_buffer *buffer, unsigned long value);
void	write_hex(t_buffer *buffer, unsigned long value, int uppercase);

#endif
