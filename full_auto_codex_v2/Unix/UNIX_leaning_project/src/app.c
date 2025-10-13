#include "ft_select.h"

#include <stdlib.h>
#include <string.h>
#include <term.h>
#include <unistd.h>
#include <stdio.h>

static int  tc_putchar(int c)
{
    return write(STDOUT_FILENO, &c, 1);
}

t_app g_app = {0};

static int  setup_termcaps(t_app *app)
{
    char            term_buffer[2048];
    char            cap_buffer[2048];
    char            *area;
    const char      *termname;

    termname = getenv("TERM");
    if (!termname || !*termname)
    {
        fprintf(stderr, "ft_select: TERM not set\n");
        return (-1);
    }
    if (tgetent(term_buffer, termname) <= 0)
    {
        fprintf(stderr, "ft_select: tgetent failed\n");
        return (-1);
    }
    area = cap_buffer;
    app->cap.cl = tgetstr("cl", &area);
    app->cap.cm = tgetstr("cm", &area);
    app->cap.so = tgetstr("so", &area);
    app->cap.se = tgetstr("se", &area);
    app->cap.us = tgetstr("us", &area);
    app->cap.ue = tgetstr("ue", &area);
    app->cap.vi = tgetstr("vi", &area);
    app->cap.ve = tgetstr("ve", &area);
    if (!app->cap.cl || !app->cap.cm)
    {
        fprintf(stderr, "ft_select: required termcap missing\n");
        return (-1);
    }
    tputs(app->cap.vi ? app->cap.vi : "", 1, tc_putchar);
    return (0);
}

void app_enable_raw_mode(t_app *app)
{
    struct termios tty;

    tcgetattr(STDIN_FILENO, &app->orig_term);
    tty = app->orig_term;
    tty.c_lflag &= ~(ICANON | ECHO);
    tty.c_lflag |= ISIG;
    tty.c_cc[VMIN] = 1;
    tty.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &tty);
}

void app_restore_terminal(t_app *app)
{
    tcsetattr(STDIN_FILENO, TCSANOW, &app->orig_term);
    if (app->cap.ve)
        tputs(app->cap.ve, 1, tc_putchar);
    if (app->cap.se)
        tputs(app->cap.se, 1, tc_putchar);
    if (app->cap.ue)
        tputs(app->cap.ue, 1, tc_putchar);
}

static int  duplicate_items(t_app *app, int count, char **argv)
{
    size_t i;

    app->items = calloc((size_t)count, sizeof(t_item));
    if (!app->items)
        return (-1);
    for (i = 0; i < (size_t)count; ++i)
    {
        app->items[i].label = strdup(argv[i]);
        if (!app->items[i].label)
            return (-1);
    }
    app->count = (size_t)count;
    app->index = 0;
    return (0);
}

int app_init(t_app *app, int argc, char **argv)
{
    if (argc <= 1)
    {
        fprintf(stderr, "Usage: ft_select item1 item2 ...\n");
        return (-1);
    }
    if (!isatty(STDIN_FILENO) || !isatty(STDOUT_FILENO))
    {
        fprintf(stderr, "ft_select: stdin/stdout must be a tty\n");
        return (-1);
    }
    if (duplicate_items(app, argc - 1, &argv[1]) == -1)
        return (-1);
    app_enable_raw_mode(app);
    if (setup_termcaps(app) == -1)
    {
        app_restore_terminal(app);
        return (-1);
    }
    app->running = 1;
    app->need_redraw = 1;
    app->emit_selection = 0;
    return (0);
}

void app_cleanup(t_app *app)
{
    size_t i;

    if (app->items)
    {
        for (i = 0; i < app->count; ++i)
            free(app->items[i].label);
        free(app->items);
        app->items = NULL;
    }
    free(app->layout_map);
    app->layout_map = NULL;
}

void app_output_selection(t_app *app)
{
    size_t  visible = 0;

    for (size_t i = 0; i < app->count; ++i)
    {
        if (!app->items[i].deleted && app->items[i].selected)
        {
            if (visible++ > 0)
                write(STDOUT_FILENO, " ", 1);
            write(STDOUT_FILENO, app->items[i].label, strlen(app->items[i].label));
        }
    }
    write(STDOUT_FILENO, "\n", 1);
}

void app_abort_without_output(void)
{
    app_restore_terminal(&g_app);
    write(STDOUT_FILENO, "\n", 1);
}

int app_visible_count(const t_app *app)
{
    int count = 0;
    for (size_t i = 0; i < app->count; ++i)
        if (!app->items[i].deleted)
            count++;
    return count;
}

int app_next_visible(const t_app *app, int start, int direction)
{
    int count = (int)app->count;
    int idx = start;

    if (count == 0)
        return -1;
    while (1)
    {
        idx = (idx + direction + count) % count;
        if (!app->items[idx].deleted)
            return idx;
        if (idx == start)
            break;
    }
    return start;
}

int app_is_window_too_small(t_app *app, int visible, int max_len);
void app_redraw(t_app *app, int visible, int max_len);
void app_handle_input(t_app *app);
void app_setup_signals(t_app *app);

void app_mainloop(t_app *app)
{
    app_setup_signals(app);
    while (app->running)
    {
        if (app->need_redraw)
        {
            int visible = app_visible_count(app);
            int max_len = 0;
            for (size_t i = 0; i < app->count; ++i)
                if (!app->items[i].deleted)
                {
                    int len = (int)strlen(app->items[i].label);
                    if (len > max_len)
                        max_len = len;
                }
            app->need_redraw = 0;
            app_redraw(app, visible, max_len);
        }
        app_handle_input(app);
    }
}

int app_is_window_too_small(t_app *app, int visible, int max_len)
{
    struct winsize ws;

    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == -1)
    {
        app->win_cols = 80;
        app->win_rows = 24;
    }
    else
    {
        app->win_cols = ws.ws_col;
        app->win_rows = ws.ws_row;
    }
    if (visible == 0)
        return 0;
    int min_width = max_len + 2;
    int cols = app->win_cols / (min_width ? min_width : 1);
    if (cols < 1)
        cols = 1;
    int rows;
    while (cols > 0)
    {
        rows = (visible + cols - 1) / cols;
        if (rows <= app->win_rows)
            break;
        cols--;
    }
    if (cols == 0)
        return 1;
    app->layout_cols = cols;
    app->layout_rows = rows;
    return 0;
}

void app_redraw(t_app *app, int visible, int max_len)
{
    free(app->layout_map);
    app->layout_map = NULL;
    app->layout_count = 0;

    if (app_is_window_too_small(app, visible, max_len))
    {
        tputs(app->cap.cl, 1, tc_putchar);
        write(STDOUT_FILENO, "Window too small", 17);
        return;
    }
    tputs(app->cap.cl, 1, tc_putchar);

    if (visible == 0)
        return;

    app->layout_map = malloc(sizeof(int) * (size_t)visible);
    if (!app->layout_map)
        return;
    app->layout_count = (size_t)visible;

    int width = max_len + 2;
    int rows = app->layout_rows;
    int cols = app->layout_cols;
    int pos = 0;

    for (size_t i = 0; i < app->count; ++i)
    {
        if (app->items[i].deleted)
            continue;
        app->layout_map[pos++] = (int)i;
    }

    for (int col = 0; col < cols; ++col)
    {
        for (int row = 0; row < rows; ++row)
        {
            int index = col * rows + row;
            if (index >= visible)
                continue;
            int item_idx = app->layout_map[index];
            int x = col * width;
            int y = row;
            if (app->cap.cm)
            {
                char *pos_str = tgoto(app->cap.cm, x, y);
                tputs(pos_str, 1, tc_putchar);
            }
            if (app->items[item_idx].selected && app->cap.so)
                tputs(app->cap.so, 1, tc_putchar);
            if ((size_t)item_idx == app->index && app->cap.us)
                tputs(app->cap.us, 1, tc_putchar);
            write(STDOUT_FILENO, app->items[item_idx].label, strlen(app->items[item_idx].label));
            if (app->items[item_idx].selected && app->cap.se)
                tputs(app->cap.se, 1, tc_putchar);
            if ((size_t)item_idx == app->index && app->cap.ue)
                tputs(app->cap.ue, 1, tc_putchar);
            size_t label_len = strlen(app->items[item_idx].label);
            for (int k = 0; k < width - (int)label_len; ++k)
                write(STDOUT_FILENO, " ", 1);
        }
    }
}
