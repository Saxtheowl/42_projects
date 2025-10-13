#include "ft_select.h"

#include <stdio.h>
#include <stdlib.h>

extern t_app g_app;

int main(int argc, char **argv)
{
    if (app_init(&g_app, argc, argv) == -1)
        return (EXIT_FAILURE);
    app_mainloop(&g_app);
    app_restore_terminal(&g_app);
    if (g_app.emit_selection)
        app_output_selection(&g_app);
    app_cleanup(&g_app);
    if (!g_app.emit_selection)
        return (EXIT_FAILURE);
    return (EXIT_SUCCESS);
}
