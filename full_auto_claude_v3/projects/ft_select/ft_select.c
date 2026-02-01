/* ************************************************************************** */
/*                                                                            */
/*   ft_select - Terminal argument selector                                   */
/*   Interactive selection of arguments using arrow keys                      */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <signal.h>
#include <sys/ioctl.h>

#define MAX_ARGS 1000

typedef struct s_select
{
	char			**args;
	int				*selected;
	int				count;
	int				cursor;
	struct termios	orig_termios;
	int				cols;
	int				rows;
}	t_select;

static t_select	g_select;

/* Terminal control sequences */
#define CLEAR_SCREEN	"\033[2J"
#define CURSOR_HOME		"\033[H"
#define CURSOR_HIDE		"\033[?25l"
#define CURSOR_SHOW		"\033[?25h"
#define BOLD			"\033[1m"
#define UNDERLINE		"\033[4m"
#define REVERSE			"\033[7m"
#define RESET			"\033[0m"

static void	cleanup(void)
{
	tcsetattr(STDIN_FILENO, TCSANOW, &g_select.orig_termios);
	write(STDOUT_FILENO, CURSOR_SHOW, strlen(CURSOR_SHOW));
	write(STDOUT_FILENO, CLEAR_SCREEN CURSOR_HOME,
		  strlen(CLEAR_SCREEN CURSOR_HOME));
}

static void	signal_handler(int sig)
{
	if (sig == SIGINT || sig == SIGTERM)
	{
		cleanup();
		exit(0);
	}
	else if (sig == SIGWINCH)
	{
		struct winsize ws;
		if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0)
		{
			g_select.cols = ws.ws_col;
			g_select.rows = ws.ws_row;
		}
	}
}

static int	setup_terminal(void)
{
	struct termios	raw;
	struct winsize	ws;

	if (tcgetattr(STDIN_FILENO, &g_select.orig_termios) < 0)
		return (-1);

	raw = g_select.orig_termios;
	raw.c_lflag &= ~(ECHO | ICANON | ISIG);
	raw.c_cc[VMIN] = 1;
	raw.c_cc[VTIME] = 0;

	if (tcsetattr(STDIN_FILENO, TCSANOW, &raw) < 0)
		return (-1);

	if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0)
	{
		g_select.cols = ws.ws_col;
		g_select.rows = ws.ws_row;
	}
	else
	{
		g_select.cols = 80;
		g_select.rows = 24;
	}

	return (0);
}

static void	render(void)
{
	int		i;
	int		col;
	int		max_len;
	int		items_per_row;
	char	buf[4096];
	int		len;

	/* Find max argument length */
	max_len = 0;
	for (i = 0; i < g_select.count; i++)
	{
		int arglen = strlen(g_select.args[i]);
		if (arglen > max_len)
			max_len = arglen;
	}
	max_len += 4;  /* Padding */

	items_per_row = g_select.cols / max_len;
	if (items_per_row < 1)
		items_per_row = 1;

	/* Clear screen */
	len = snprintf(buf, sizeof(buf), CURSOR_HIDE CURSOR_HOME);

	/* Print header */
	len += snprintf(buf + len, sizeof(buf) - len,
					"ft_select - Use arrows to move, Space to select, Enter to confirm, Q to quit\n\n");

	/* Print arguments */
	col = 0;
	for (i = 0; i < g_select.count; i++)
	{
		/* Cursor indicator */
		if (i == g_select.cursor)
			len += snprintf(buf + len, sizeof(buf) - len, REVERSE);

		/* Selection indicator */
		if (g_select.selected[i])
			len += snprintf(buf + len, sizeof(buf) - len, UNDERLINE);

		len += snprintf(buf + len, sizeof(buf) - len, "%-*s",
						max_len, g_select.args[i]);

		len += snprintf(buf + len, sizeof(buf) - len, RESET);

		col++;
		if (col >= items_per_row)
		{
			len += snprintf(buf + len, sizeof(buf) - len, "\n");
			col = 0;
		}
	}

	if (col != 0)
		len += snprintf(buf + len, sizeof(buf) - len, "\n");

	/* Print status */
	int selected_count = 0;
	for (i = 0; i < g_select.count; i++)
		if (g_select.selected[i])
			selected_count++;

	len += snprintf(buf + len, sizeof(buf) - len,
					"\n%d of %d selected\n", selected_count, g_select.count);

	write(STDOUT_FILENO, buf, len);
}

static int	read_key(void)
{
	char	c;
	char	seq[3];

	if (read(STDIN_FILENO, &c, 1) != 1)
		return (-1);

	if (c == '\033')
	{
		/* Escape sequence */
		if (read(STDIN_FILENO, &seq[0], 1) != 1)
			return ('\033');
		if (read(STDIN_FILENO, &seq[1], 1) != 1)
			return ('\033');

		if (seq[0] == '[')
		{
			switch (seq[1])
			{
				case 'A': return (1000);  /* Up */
				case 'B': return (1001);  /* Down */
				case 'C': return (1002);  /* Right */
				case 'D': return (1003);  /* Left */
			}
		}
		return ('\033');
	}
	return (c);
}

static void	move_cursor(int direction)
{
	int	max_len;
	int	items_per_row;
	int	i;

	max_len = 0;
	for (i = 0; i < g_select.count; i++)
	{
		int arglen = strlen(g_select.args[i]);
		if (arglen > max_len)
			max_len = arglen;
	}
	max_len += 4;

	items_per_row = g_select.cols / max_len;
	if (items_per_row < 1)
		items_per_row = 1;

	switch (direction)
	{
		case 1000:  /* Up */
			g_select.cursor -= items_per_row;
			if (g_select.cursor < 0)
				g_select.cursor = g_select.count - 1;
			break;
		case 1001:  /* Down */
			g_select.cursor += items_per_row;
			if (g_select.cursor >= g_select.count)
				g_select.cursor = 0;
			break;
		case 1002:  /* Right */
			g_select.cursor++;
			if (g_select.cursor >= g_select.count)
				g_select.cursor = 0;
			break;
		case 1003:  /* Left */
			g_select.cursor--;
			if (g_select.cursor < 0)
				g_select.cursor = g_select.count - 1;
			break;
	}
}

static void	print_selected(void)
{
	int		i;
	int		first;

	first = 1;
	for (i = 0; i < g_select.count; i++)
	{
		if (g_select.selected[i])
		{
			if (!first)
				write(STDOUT_FILENO, " ", 1);
			write(STDOUT_FILENO, g_select.args[i], strlen(g_select.args[i]));
			first = 0;
		}
	}
	write(STDOUT_FILENO, "\n", 1);
}

int	main(int argc, char **argv)
{
	int	key;
	int	running;

	if (argc < 2)
	{
		printf("Usage: %s arg1 [arg2 ...]\n", argv[0]);
		printf("Interactive selection of arguments\n");
		printf("\nControls:\n");
		printf("  Arrow keys  - Move cursor\n");
		printf("  Space       - Toggle selection\n");
		printf("  Enter       - Confirm and print selected\n");
		printf("  Delete      - Remove argument from list\n");
		printf("  Q/Esc       - Quit without selection\n");
		return (0);
	}

	/* Initialize */
	g_select.args = argv + 1;
	g_select.count = argc - 1;
	g_select.cursor = 0;
	g_select.selected = calloc(g_select.count, sizeof(int));
	if (!g_select.selected)
		return (1);

	/* Setup */
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGWINCH, signal_handler);

	if (setup_terminal() < 0)
	{
		fprintf(stderr, "Failed to setup terminal\n");
		free(g_select.selected);
		return (1);
	}

	/* Main loop */
	running = 1;
	while (running)
	{
		render();

		key = read_key();
		switch (key)
		{
			case 'q':
			case 'Q':
			case '\033':
				running = 0;
				break;

			case '\n':
			case '\r':
				cleanup();
				print_selected();
				running = 0;
				break;

			case ' ':
				g_select.selected[g_select.cursor] ^= 1;
				move_cursor(1002);  /* Move right after selection */
				break;

			case 127:  /* Delete/Backspace */
				/* Remove current item */
				if (g_select.count > 1)
				{
					for (int i = g_select.cursor; i < g_select.count - 1; i++)
					{
						g_select.args[i] = g_select.args[i + 1];
						g_select.selected[i] = g_select.selected[i + 1];
					}
					g_select.count--;
					if (g_select.cursor >= g_select.count)
						g_select.cursor = g_select.count - 1;
				}
				break;

			case 1000:
			case 1001:
			case 1002:
			case 1003:
				move_cursor(key);
				break;
		}
	}

	if (key == 'q' || key == 'Q' || key == '\033')
		cleanup();

	free(g_select.selected);
	return (0);
}
