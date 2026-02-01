/* ************************************************************************** */
/*                                                                            */
/*   ft_script - Terminal session recorder                                    */
/*   Records terminal session to typescript file                              */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/select.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <pty.h>

#define BUFFER_SIZE 4096
#define DEFAULT_OUTPUT "typescript"

typedef struct s_script
{
	int				master_fd;
	int				output_fd;
	pid_t			child_pid;
	struct termios	orig_termios;
	int				quiet;
	int				append;
	int				timing;
	char			*output_file;
	char			*timing_file;
	int				timing_fd;
}	t_script;

static t_script	g_script;

static void	cleanup(void)
{
	/* Restore terminal settings */
	tcsetattr(STDIN_FILENO, TCSANOW, &g_script.orig_termios);

	if (g_script.output_fd >= 0)
	{
		dprintf(g_script.output_fd, "\nScript done on %s",
			ctime(&(time_t){time(NULL)}));
		close(g_script.output_fd);
	}
	if (g_script.timing_fd >= 0)
		close(g_script.timing_fd);
}

static void	signal_handler(int sig)
{
	(void)sig;
	cleanup();
	exit(0);
}

static void	setup_signals(void)
{
	struct sigaction	sa;

	sa.sa_handler = signal_handler;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = 0;
	sigaction(SIGINT, &sa, NULL);
	sigaction(SIGTERM, &sa, NULL);
	sigaction(SIGHUP, &sa, NULL);
}

static int	setup_terminal(void)
{
	struct termios	raw;

	if (tcgetattr(STDIN_FILENO, &g_script.orig_termios) < 0)
	{
		perror("tcgetattr");
		return (-1);
	}

	raw = g_script.orig_termios;
	raw.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN);
	raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
	raw.c_oflag &= ~(OPOST);
	raw.c_cflag |= (CS8);
	raw.c_cc[VMIN] = 1;
	raw.c_cc[VTIME] = 0;

	if (tcsetattr(STDIN_FILENO, TCSANOW, &raw) < 0)
	{
		perror("tcsetattr");
		return (-1);
	}
	return (0);
}

static void	forward_window_size(int sig)
{
	struct winsize	ws;

	(void)sig;
	if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) == 0)
		ioctl(g_script.master_fd, TIOCSWINSZ, &ws);
}

static int	open_output_file(void)
{
	int	flags;

	flags = O_WRONLY | O_CREAT;
	if (g_script.append)
		flags |= O_APPEND;
	else
		flags |= O_TRUNC;

	g_script.output_fd = open(g_script.output_file, flags, 0644);
	if (g_script.output_fd < 0)
	{
		perror("open output file");
		return (-1);
	}

	if (g_script.timing && g_script.timing_file)
	{
		g_script.timing_fd = open(g_script.timing_file, flags, 0644);
		if (g_script.timing_fd < 0)
		{
			perror("open timing file");
			close(g_script.output_fd);
			return (-1);
		}
	}

	return (0);
}

static void	write_timing(size_t bytes)
{
	static struct timespec	last_time = {0, 0};
	struct timespec			now;
	double					elapsed;

	if (g_script.timing_fd < 0)
		return;

	clock_gettime(CLOCK_MONOTONIC, &now);

	if (last_time.tv_sec == 0 && last_time.tv_nsec == 0)
	{
		elapsed = 0;
	}
	else
	{
		elapsed = (now.tv_sec - last_time.tv_sec) +
				  (now.tv_nsec - last_time.tv_nsec) / 1000000000.0;
	}

	dprintf(g_script.timing_fd, "%.6f %zu\n", elapsed, bytes);
	last_time = now;
}

static void	child_process(char **shell_argv)
{
	char	*shell;
	char	*argv[2];

	/* Get shell */
	shell = getenv("SHELL");
	if (!shell)
		shell = "/bin/sh";

	/* Setup argv */
	if (shell_argv && shell_argv[0])
	{
		execvp(shell_argv[0], shell_argv);
	}
	else
	{
		argv[0] = shell;
		argv[1] = NULL;
		execvp(shell, argv);
	}

	perror("execvp");
	exit(1);
}

static int	main_loop(void)
{
	fd_set			readfds;
	char			buf[BUFFER_SIZE];
	ssize_t			n;
	int				status;
	int				maxfd;

	maxfd = (g_script.master_fd > STDIN_FILENO) ?
			g_script.master_fd : STDIN_FILENO;

	while (1)
	{
		FD_ZERO(&readfds);
		FD_SET(STDIN_FILENO, &readfds);
		FD_SET(g_script.master_fd, &readfds);

		if (select(maxfd + 1, &readfds, NULL, NULL, NULL) < 0)
		{
			if (errno == EINTR)
				continue;
			break;
		}

		/* Input from user -> send to PTY */
		if (FD_ISSET(STDIN_FILENO, &readfds))
		{
			n = read(STDIN_FILENO, buf, sizeof(buf));
			if (n <= 0)
				break;
			if (write(g_script.master_fd, buf, n) != n)
				break;
		}

		/* Output from PTY -> display and record */
		if (FD_ISSET(g_script.master_fd, &readfds))
		{
			n = read(g_script.master_fd, buf, sizeof(buf));
			if (n <= 0)
				break;

			/* Write to terminal */
			if (write(STDOUT_FILENO, buf, n) != n)
				break;

			/* Write to output file */
			if (write(g_script.output_fd, buf, n) != n)
				break;

			/* Write timing info */
			if (g_script.timing)
				write_timing(n);
		}
	}

	/* Wait for child */
	waitpid(g_script.child_pid, &status, 0);
	return (WIFEXITED(status) ? WEXITSTATUS(status) : 1);
}

static void	print_usage(char *progname)
{
	printf("Usage: %s [options] [file]\n", progname);
	printf("Options:\n");
	printf("  -a        Append to output file\n");
	printf("  -q        Quiet mode (don't print start/end messages)\n");
	printf("  -t file   Write timing to file (for scriptreplay)\n");
	printf("  -c cmd    Run command instead of shell\n");
	printf("  -h        Show this help\n");
	printf("\nDefault output file: %s\n", DEFAULT_OUTPUT);
}

int	main(int argc, char **argv)
{
	struct winsize	ws;
	int				opt;
	char			*command = NULL;
	char			*cmd_argv[4];

	/* Initialize */
	memset(&g_script, 0, sizeof(g_script));
	g_script.output_file = DEFAULT_OUTPUT;
	g_script.output_fd = -1;
	g_script.timing_fd = -1;

	/* Parse options */
	while ((opt = getopt(argc, argv, "aqt:c:h")) != -1)
	{
		switch (opt)
		{
			case 'a':
				g_script.append = 1;
				break;
			case 'q':
				g_script.quiet = 1;
				break;
			case 't':
				g_script.timing = 1;
				g_script.timing_file = optarg;
				break;
			case 'c':
				command = optarg;
				break;
			case 'h':
				print_usage(argv[0]);
				return (0);
			default:
				print_usage(argv[0]);
				return (1);
		}
	}

	/* Output file from remaining args */
	if (optind < argc)
		g_script.output_file = argv[optind];

	/* Open output file */
	if (open_output_file() < 0)
		return (1);

	/* Write header */
	dprintf(g_script.output_fd, "Script started on %s",
		ctime(&(time_t){time(NULL)}));

	if (!g_script.quiet)
		printf("Script started, file is %s\n", g_script.output_file);

	/* Get terminal size */
	if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) < 0)
	{
		ws.ws_row = 24;
		ws.ws_col = 80;
	}

	/* Create pseudo-terminal */
	g_script.child_pid = forkpty(&g_script.master_fd, NULL, NULL, &ws);

	if (g_script.child_pid < 0)
	{
		perror("forkpty");
		return (1);
	}

	if (g_script.child_pid == 0)
	{
		/* Child process */
		if (command)
		{
			cmd_argv[0] = "/bin/sh";
			cmd_argv[1] = "-c";
			cmd_argv[2] = command;
			cmd_argv[3] = NULL;
			child_process(cmd_argv);
		}
		else
		{
			child_process(NULL);
		}
	}

	/* Parent process */
	setup_signals();

	/* Handle window resize */
	signal(SIGWINCH, forward_window_size);

	/* Set raw terminal mode */
	if (setup_terminal() < 0)
	{
		kill(g_script.child_pid, SIGTERM);
		return (1);
	}

	/* Main loop */
	int ret = main_loop();

	/* Cleanup */
	cleanup();

	if (!g_script.quiet)
		printf("Script done, file is %s\n", g_script.output_file);

	return (ret);
}
