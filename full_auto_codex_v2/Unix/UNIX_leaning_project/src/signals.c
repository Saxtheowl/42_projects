#include "ft_select.h"

#include <signal.h>
#include <stdio.h>
#include <term.h>
#include <unistd.h>

extern t_app g_app;

static void handle_exit(int sig)
{
    (void)sig;
    g_app.emit_selection = 0;
    g_app.running = 0;
}

static void handle_winch(int sig)
{
    (void)sig;
    g_app.need_redraw = 1;
}

static void handle_tstp(int sig)
{
    (void)sig;
    app_restore_terminal(&g_app);
    signal(SIGTSTP, SIG_DFL);
    raise(SIGTSTP);
}

static int signal_putchar(int c)
{
    return write(STDOUT_FILENO, &c, 1);
}

static void handle_cont(int sig)
{
    (void)sig;
    app_enable_raw_mode(&g_app);
    if (g_app.cap.vi)
        tputs(g_app.cap.vi, 1, signal_putchar);
    g_app.need_redraw = 1;
    signal(SIGTSTP, handle_tstp);
}

void app_setup_signals(t_app *app)
{
    (void)app;
    signal(SIGWINCH, handle_winch);
    signal(SIGINT, handle_exit);
    signal(SIGTERM, handle_exit);
    signal(SIGQUIT, handle_exit);
    signal(SIGTSTP, handle_tstp);
    signal(SIGCONT, handle_cont);
}
