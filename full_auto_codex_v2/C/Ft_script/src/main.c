#define _XOPEN_SOURCE 600
#include <errno.h>
#include <fcntl.h>
#include <pty.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>
#include <utmp.h>

typedef struct s_opts
{
    int         append;
    int         flush;
    int         quiet;
    int         return_child;
    const char  *cmd;
    const char  *outfile;
}   t_opts;

typedef struct s_ctx
{
    int use_pty;
    int master_fd;
    int in_pipe[2];
    int out_pipe[2];
}   t_ctx;

static int  g_use_pty = 0;
static int  g_master_fd = -1;

static void die(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

static void usage(void)
{
    fprintf(stderr, "usage: ft_script [-a] [-e] [-f] [-q] [-c command] [file]\n");
    exit(EXIT_FAILURE);
}

static void parse_opts(int argc, char **argv, t_opts *opts)
{
    opts->append = 0;
    opts->flush = 0;
    opts->quiet = 0;
    opts->cmd = NULL;
    opts->outfile = "typescript";
    opts->return_child = 0;
    int c;
    while ((c = getopt(argc, argv, "aefqc:")) != -1)
    {
        if (c == 'a')
            opts->append = 1;
        else if (c == 'e')
            opts->return_child = 1;
        else if (c == 'f')
            opts->flush = 1;
        else if (c == 'q')
            opts->quiet = 1;
        else if (c == 'c')
            opts->cmd = optarg;
        else
            usage();
    }
    if (optind < argc)
    {
        opts->outfile = argv[optind];
        optind++;
    }
    if (optind != argc)
        usage();
}

static void safe_write(int fd, const char *buf, size_t len, int do_flush)
{
    size_t off = 0;
    while (off < len)
    {
        ssize_t w = write(fd, buf + off, len - off);
        if (w <= 0)
            die("ft_script: write");
        off += (size_t)w;
    }
    if (do_flush)
        fsync(fd);
}

static void setup_pty_or_pipe(t_ctx *ctx, const t_opts *opts)
{
    ctx->use_pty = 0;
    ctx->master_fd = -1;
    if (openpty(&ctx->master_fd, &ctx->out_pipe[1], NULL, NULL, NULL) == 0)
    {
        ctx->use_pty = 1;
    }
    else
    {
        if (pipe(ctx->in_pipe) == -1 || pipe(ctx->out_pipe) == -1)
            die("ft_script: pipe");
    }
    (void)opts;
}

static void apply_winsize(int fd)
{
    struct winsize ws;
    if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) == -1)
        return;
    ioctl(fd, TIOCSWINSZ, &ws);
}

static void handle_winch(int sig)
{
    (void)sig;
    if (g_use_pty && g_master_fd != -1)
        apply_winsize(g_master_fd);
}

static void install_signals(void)
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_winch;
    sigaction(SIGWINCH, &sa, NULL);
}

int main(int argc, char **argv)
{
    t_opts opts;
    parse_opts(argc, argv, &opts);

    int out_fd = open(opts.outfile,
                      O_WRONLY | O_CREAT | (opts.append ? O_APPEND : O_TRUNC),
                      0644);
    if (out_fd < 0)
        die("ft_script: open output");

    t_ctx ctx;
    setup_pty_or_pipe(&ctx, &opts);
    g_use_pty = ctx.use_pty;
    g_master_fd = ctx.master_fd;
    if (ctx.use_pty)
        install_signals();

    pid_t pid = fork();
    if (pid == -1)
        die("ft_script: fork");
    if (pid == 0)
    {
        if (ctx.use_pty)
        {
            close(ctx.master_fd);
            apply_winsize(ctx.out_pipe[1]);
            if (login_tty(ctx.out_pipe[1]) == -1)
                die("ft_script: login_tty");
        }
        else
        {
            /* Child: stdin from in_pipe[0], stdout/stderr to out_pipe[1] */
            close(ctx.in_pipe[1]);
            close(ctx.out_pipe[0]);
            if (dup2(ctx.in_pipe[0], STDIN_FILENO) == -1 ||
                dup2(ctx.out_pipe[1], STDOUT_FILENO) == -1 ||
                dup2(ctx.out_pipe[1], STDERR_FILENO) == -1)
                die("ft_script: dup2");
            close(ctx.in_pipe[0]);
            close(ctx.out_pipe[1]);
        }
        const char *shell = getenv("SHELL");
        if (!shell)
            shell = "/bin/sh";
        if (opts.cmd)
            execlp(shell, shell, "-c", opts.cmd, (char *)NULL);
        else
            execlp(shell, shell, "-i", (char *)NULL);
        die("ft_script: exec shell");
    }
    /* Parent */
    if (ctx.use_pty)
    {
        apply_winsize(ctx.master_fd);
        close(ctx.out_pipe[1]);
    }
    else
    {
        close(ctx.in_pipe[0]);
        close(ctx.out_pipe[1]);
    }
    char msg[256];
    int len = snprintf(msg, sizeof(msg), "Script started, output file is %s\n", opts.outfile);
    if (!opts.quiet)
        safe_write(STDOUT_FILENO, msg, (size_t)len, 0);
    len = snprintf(msg, sizeof(msg), "Script started on %s", ctime(&(time_t){time(NULL)}));
    safe_write(out_fd, msg, (size_t)len, opts.flush);

    fd_set readfds;
    char buf[4096];
    int done = 0;
    while (!done)
    {
        FD_ZERO(&readfds);
        FD_SET(STDIN_FILENO, &readfds);
        int data_fd = ctx.use_pty ? ctx.master_fd : ctx.out_pipe[0];
        FD_SET(data_fd, &readfds);
        int nfds = (STDIN_FILENO > data_fd ? STDIN_FILENO : data_fd) + 1;
        int r = select(nfds, &readfds, NULL, NULL, NULL);
        if (r == -1)
        {
            if (errno == EINTR)
                continue;
            die("ft_script: select");
        }
        if (FD_ISSET(STDIN_FILENO, &readfds))
        {
            ssize_t n = read(STDIN_FILENO, buf, sizeof(buf));
            if (n <= 0)
            {
                if (!ctx.use_pty)
                    close(ctx.in_pipe[1]);
            }
            else
            {
                if (ctx.use_pty)
                    safe_write(ctx.master_fd, buf, (size_t)n, 0);
                else
                    safe_write(ctx.in_pipe[1], buf, (size_t)n, 0);
            }
        }
        if (FD_ISSET(data_fd, &readfds))
        {
            ssize_t n = read(data_fd, buf, sizeof(buf));
            if (n <= 0)
                done = 1;
            else
            {
                safe_write(STDOUT_FILENO, buf, (size_t)n, 0);
                safe_write(out_fd, buf, (size_t)n, opts.flush);
            }
        }
    }
    if (ctx.use_pty)
        close(ctx.master_fd);
    else
    {
        close(ctx.out_pipe[0]);
        close(ctx.in_pipe[1]);
    }
    int status = 0;
    waitpid(pid, &status, 0);
    len = snprintf(msg, sizeof(msg), "\nScript done on %s", ctime(&(time_t){time(NULL)}));
    safe_write(out_fd, msg, (size_t)len, opts.flush);
    len = snprintf(msg, sizeof(msg), "Script done, output file is %s\n", opts.outfile);
    if (!opts.quiet)
        safe_write(STDOUT_FILENO, msg, (size_t)len, 0);
    close(out_fd);
    int child_rc = (WIFEXITED(status) ? WEXITSTATUS(status) : EXIT_FAILURE);
    if (opts.return_child)
        return child_rc;
    return 0;
}
