#include "ft_select.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <term.h>
#include <unistd.h>

extern t_app g_app;

static ssize_t read_key(unsigned char *buf, size_t size)
{
    ssize_t n;

    n = read(STDIN_FILENO, buf, 1);
    if (n <= 0)
        return n;
    if (buf[0] == 0x1B)
    {
        struct timeval tv;
        fd_set      readfds;

        while (n < (ssize_t)size)
        {
            FD_ZERO(&readfds);
            FD_SET(STDIN_FILENO, &readfds);
            tv.tv_sec = 0;
            tv.tv_usec = 10000;
            if (select(STDIN_FILENO + 1, &readfds, NULL, NULL, &tv) <= 0)
                break;
            ssize_t m = read(STDIN_FILENO, buf + n, size - (size_t)n);
            if (m <= 0)
                break;
            n += m;
        }
    }
    return n;
}

static int find_position_by_index(const t_app *app, size_t index)
{
    if (!app->layout_map)
        return -1;
    for (size_t i = 0; i < app->layout_count; ++i)
        if ((size_t)app->layout_map[i] == index)
            return (int)i;
    return -1;
}

static void move_vertical(t_app *app, int direction)
{
    if (!app->layout_map || app->layout_count == 0)
        return ;
    int rows = app->layout_rows;
    int cols = app->layout_cols;
    if (rows <= 0 || cols <= 0)
        return ;
    int pos = find_position_by_index(app, app->index);
    if (pos < 0)
        pos = 0;
    int col = pos / rows;
    int row = pos % rows;
    int attempts = rows;
    while (attempts-- > 0)
    {
        row = (row + direction + rows) % rows;
        int candidate = col * rows + row;
        if (candidate < (int)app->layout_count)
        {
            app->index = (size_t)app->layout_map[candidate];
            app->need_redraw = 1;
            return ;
        }
    }
}

static void move_horizontal(t_app *app, int direction)
{
    if (!app->layout_map || app->layout_count == 0)
        return ;
    int rows = app->layout_rows;
    int cols = app->layout_cols;
    if (rows <= 0 || cols <= 0)
        return ;
    int pos = find_position_by_index(app, app->index);
    if (pos < 0)
        pos = 0;
    int row = pos % rows;
    int col = pos / rows;
    int attempts = cols;
    while (attempts-- > 0)
    {
        col = (col + direction + cols) % cols;
        int candidate = col * rows + row;
        if (candidate < (int)app->layout_count)
        {
            app->index = (size_t)app->layout_map[candidate];
            app->need_redraw = 1;
            return ;
        }
        for (int r = rows - 1; r >= 0; --r)
        {
            candidate = col * rows + r;
            if (candidate < (int)app->layout_count)
            {
                app->index = (size_t)app->layout_map[candidate];
                app->need_redraw = 1;
                return ;
            }
        }
    }
}

static void select_toggle(t_app *app)
{
    if (app->count == 0)
        return ;
    if (app->items[app->index].deleted)
        return ;
    app->items[app->index].selected = !app->items[app->index].selected;
    app->need_redraw = 1;
    int next = app_next_visible(app, (int)app->index, 1);
    app->index = (size_t)next;
}

static void delete_current(t_app *app)
{
    if (app->count == 0)
        return ;
    if (app->items[app->index].deleted)
        return ;
    app->items[app->index].deleted = 1;
    app->need_redraw = 1;
    if (app_visible_count(app) == 0)
    {
        app->running = 0;
        app->emit_selection = 0;
        return ;
    }
    int next = app_next_visible(app, (int)app->index, 1);
    app->index = (size_t)next;
}

static void handle_escape_sequence(t_app *app, const unsigned char *buf, ssize_t n)
{
    if (n == 1)
    {
        app->emit_selection = 0;
        app->running = 0;
        return ;
    }
    if (buf[1] == '[')
    {
        switch (buf[2])
        {
            case 'A':
                move_vertical(app, -1);
                break;
            case 'B':
                move_vertical(app, 1);
                break;
            case 'C':
                move_horizontal(app, 1);
                break;
            case 'D':
                move_horizontal(app, -1);
                break;
            case '3':
                if (n >= 4 && buf[3] == '~')
                    delete_current(app);
                break;
            default:
                break;
        }
    }
    else if (buf[1] == 'O')
    {
        switch (buf[2])
        {
            case 'A':
                move_vertical(app, -1);
                break;
            case 'B':
                move_vertical(app, 1);
                break;
            case 'C':
                move_horizontal(app, 1);
                break;
            case 'D':
                move_horizontal(app, -1);
                break;
        }
    }
}

void app_handle_input(t_app *app)
{
    unsigned char   buf[8];
    ssize_t         n;

    n = read_key(buf, sizeof(buf));
    if (n <= 0)
        return ;
    if (buf[0] == 0x1B)
    {
        handle_escape_sequence(app, buf, n);
        return ;
    }
    if (buf[0] == ' ')
    {
        select_toggle(app);
        return ;
    }
    if (buf[0] == '\n' || buf[0] == '\r')
    {
        app->emit_selection = 1;
        app->running = 0;
        return ;
    }
    if (buf[0] == 0x7f || buf[0] == 0x08)
    {
        delete_current(app);
        return ;
    }
    if (buf[0] == 'q')
    {
        app->emit_selection = 0;
        app->running = 0;
    }
}
