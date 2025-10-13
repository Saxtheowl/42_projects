#ifndef FT_SELECT_H
#define FT_SELECT_H

#include <termios.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <stddef.h>

typedef struct s_item
{
    char    *label;
    int     selected;
    int     deleted;
}   t_item;

typedef struct s_termcap
{
    char *cl;
    char *cm;
    char *so;
    char *se;
    char *us;
    char *ue;
    char *vi;
    char *ve;
}   t_termcap;

typedef struct s_app
{
    t_item          *items;
    size_t          count;
    size_t          index;
    struct termios  orig_term;
    t_termcap       cap;
    int             win_cols;
    int             win_rows;
    int             need_redraw;
    int             running;
    int             layout_cols;
    int             layout_rows;
    int            *layout_map;
    size_t          layout_count;
    int             emit_selection;
}   t_app;

extern t_app g_app;

int     app_init(t_app *app, int argc, char **argv);
void    app_cleanup(t_app *app);
void    app_mainloop(t_app *app);
void    app_output_selection(t_app *app);
void    app_abort_without_output(void);
int     app_visible_count(const t_app *app);
int     app_next_visible(const t_app *app, int start, int direction);
void    app_restore_terminal(t_app *app);
void    app_enable_raw_mode(t_app *app);

#endif
