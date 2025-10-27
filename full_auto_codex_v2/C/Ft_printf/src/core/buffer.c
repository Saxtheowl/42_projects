#include "ft_printf.h"

void	buffer_init(t_buffer *buffer, int fd)
{
	buffer->index = 0;
	buffer->total = 0;
	buffer->error = 0;
	buffer->fd = fd;
}

void	buffer_flush(t_buffer *buffer)
{
	size_t	written;

	if (buffer->error || buffer->index == 0)
		return ;
	written = write(buffer->fd, buffer->data, buffer->index);
	if (written != buffer->index)
		buffer->error = 1;
	else
		buffer->total += written;
	buffer->index = 0;
}

void	buffer_write(t_buffer *buffer, const char *data, size_t len)
{
	size_t	offset;

	if (buffer->error)
		return ;
	offset = 0;
	while (offset < len)
	{
		if (buffer->index == sizeof(buffer->data))
			buffer_flush(buffer);
		if (buffer->error)
			return ;
		buffer->data[buffer->index++] = data[offset++];
	}
}

void	buffer_write_char(t_buffer *buffer, char c)
{
	if (buffer->error)
		return ;
	if (buffer->index == sizeof(buffer->data))
		buffer_flush(buffer);
	if (buffer->error)
		return ;
	buffer->data[buffer->index++] = c;
}
