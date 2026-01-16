#include "get_next_line.h"

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static int	open_file(const char *path)
{
	int	fd;

	fd = open(path, O_RDONLY);
	if (fd < 0)
		perror(path);
	return (fd);
}

int	main(int argc, char **argv)
{
	int		fd_a;
	int		fd_b;
	int		done_a;
	int		done_b;
	char	*line;

	if (argc < 3)
	{
		fprintf(stderr, "Usage: %s <file_a> <file_b>\n", argv[0]);
		return (1);
	}
	fd_a = open_file(argv[1]);
	if (fd_a < 0)
		return (1);
	fd_b = open_file(argv[2]);
	if (fd_b < 0)
	{
		close(fd_a);
		return (1);
	}
	done_a = 0;
	done_b = 0;
	while (!done_a || !done_b)
	{
		if (!done_a)
		{
			line = get_next_line(fd_a);
			if (line == NULL)
				done_a = 1;
			else
			{
				printf("A:%s", line);
				free(line);
			}
		}
		if (!done_b)
		{
			line = get_next_line(fd_b);
			if (line == NULL)
				done_b = 1;
			else
			{
				printf("B:%s", line);
				free(line);
			}
		}
	}
	close(fd_a);
	close(fd_b);
	return (0);
}
