#include "so_long.h"

#include <mlx.h>
#include <X11/keysym.h>
#include <stdlib.h>

#define TEX_FLOOR      "assets/textures/floor.xpm"
#define TEX_WALL       "assets/textures/wall.xpm"
#define TEX_PLAYER     "assets/textures/player.xpm"
#define TEX_COLLECT    "assets/textures/collectible.xpm"
#define TEX_EXIT_CLOSED "assets/textures/exit_closed.xpm"
#define TEX_EXIT_OPEN  "assets/textures/exit_open.xpm"

static void unload_texture(t_game *game, t_texture *texture)
{
    if (game->mlx && texture->img)
    {
        mlx_destroy_image(game->mlx, texture->img);
        texture->img = NULL;
    }
    texture->width = 0;
    texture->height = 0;
}

static void unload_assets(t_game *game)
{
    unload_texture(game, &game->assets.wall);
    unload_texture(game, &game->assets.floor);
    unload_texture(game, &game->assets.player);
    unload_texture(game, &game->assets.collectible);
    unload_texture(game, &game->assets.exit_closed);
    unload_texture(game, &game->assets.exit_open);
}

static int  load_texture(t_game *game, t_texture *texture, const char *path)
{
    texture->img = mlx_xpm_file_to_image(game->mlx, (char *)path,
            &texture->width, &texture->height);
    if (!texture->img)
        return (0);
    if (texture->width <= 0 || texture->height <= 0)
    {
        unload_texture(game, texture);
        return (0);
    }
    return (1);
}

static int  load_assets(t_game *game)
{
    int tile_size;

    if (!load_texture(game, &game->assets.floor, TEX_FLOOR))
        return (0);
    tile_size = game->assets.floor.width;
    if (game->assets.floor.height != tile_size)
        return (0);
    if (!load_texture(game, &game->assets.wall, TEX_WALL))
        return (0);
    if (!load_texture(game, &game->assets.player, TEX_PLAYER))
        return (0);
    if (!load_texture(game, &game->assets.collectible, TEX_COLLECT))
        return (0);
    if (!load_texture(game, &game->assets.exit_closed, TEX_EXIT_CLOSED))
        return (0);
    if (!load_texture(game, &game->assets.exit_open, TEX_EXIT_OPEN))
        return (0);
    if (game->assets.wall.width != tile_size
        || game->assets.wall.height != tile_size
        || game->assets.player.width != tile_size
        || game->assets.player.height != tile_size
        || game->assets.collectible.width != tile_size
        || game->assets.collectible.height != tile_size
        || game->assets.exit_closed.width != tile_size
        || game->assets.exit_closed.height != tile_size
        || game->assets.exit_open.width != tile_size
        || game->assets.exit_open.height != tile_size)
        return (0);
    game->tile_size = tile_size;
    return (1);
}

static void draw_tile(t_game *game, size_t x, size_t y)
{
    char    cell;
    void    *tile;
    int     px;
    int     py;

    px = (int)(x * game->tile_size);
    py = (int)(y * game->tile_size);
    mlx_put_image_to_window(game->mlx, game->win,
        game->assets.floor.img, px, py);
    cell = game->map.grid[y][x];
    if (cell == '1')
        tile = game->assets.wall.img;
    else if (cell == 'C')
        tile = game->assets.collectible.img;
    else if (cell == 'E')
    {
        if (game->remaining == 0)
            tile = game->assets.exit_open.img;
        else
            tile = game->assets.exit_closed.img;
    }
    else
        tile = NULL;
    if (tile)
        mlx_put_image_to_window(game->mlx, game->win, tile, px, py);
}

static void render_map(t_game *game)
{
    size_t  y;
    size_t  x;

    y = 0;
    while (y < game->map.height)
    {
        x = 0;
        while (x < game->map.width)
        {
            draw_tile(game, x, y);
            x++;
        }
        y++;
    }
}

static void draw_player(t_game *game)
{
    int px;
    int py;

    px = (int)(game->map.player_x * game->tile_size);
    py = (int)(game->map.player_y * game->tile_size);
    mlx_put_image_to_window(game->mlx, game->win,
        game->assets.player.img, px, py);
}

static void render_hud(t_game *game)
{
    char            buffer[64];
    const char      *prefix;
    size_t          i;
    size_t          len;
    size_t          moves;
    char            digits[20];

    prefix = "Moves: ";
    i = 0;
    while (prefix[i])
    {
        buffer[i] = prefix[i];
        i++;
    }
    moves = game->steps;
    if (moves == 0)
        buffer[i++] = '0';
    else
    {
        len = 0;
        while (moves > 0 && len < sizeof(digits))
        {
            digits[len++] = '0' + (moves % 10);
            moves /= 10;
        }
        while (len > 0)
            buffer[i++] = digits[--len];
    }
    buffer[i] = '\0';
    mlx_string_put(game->mlx, game->win, 10, 20, 0x00FFFFFF, buffer);
}

static void render_game(t_game *game)
{
    render_map(game);
    draw_player(game);
    render_hud(game);
}

static void announce_move(t_game *game)
{
    sl_putstr_fd("Moves: ", 1);
    sl_putnbr_fd(game->steps, 1);
    sl_putstr_fd("\n", 1);
}

static void request_close(t_game *game, const char *message)
{
    if (game->finished)
        return ;
    game->finished = 1;
    if (message)
        sl_putstr_fd(message, 1);
    if (game->mlx)
        mlx_loop_end(game->mlx);
}

static void  move_player(t_game *game, int dx, int dy)
{
    int     nx;
    int     ny;
    char    cell;

    if (game->finished)
        return ;
    nx = (int)game->map.player_x + dx;
    ny = (int)game->map.player_y + dy;
    if (nx < 0 || ny < 0
        || nx >= (int)game->map.width
        || ny >= (int)game->map.height)
        return ;
    cell = game->map.grid[ny][nx];
    if (cell == '1')
        return ;
    if (cell == 'E' && game->remaining != 0)
        return ;
    if (cell == 'C')
    {
        game->map.grid[ny][nx] = '0';
        if (game->remaining > 0)
            game->remaining--;
    }
    game->map.player_x = (size_t)nx;
    game->map.player_y = (size_t)ny;
    game->steps++;
    announce_move(game);
    render_game(game);
    if (cell == 'E' && game->remaining == 0)
        request_close(game, "You reached the exit!\n");
}

static int  handle_key(int keycode, void *param)
{
    t_game  *game;

    game = (t_game *)param;
    if (keycode == XK_Escape)
    {
        request_close(game, "Game closed.\n");
        return (0);
    }
    if (keycode == XK_w || keycode == XK_W || keycode == XK_Up)
        move_player(game, 0, -1);
    else if (keycode == XK_s || keycode == XK_S || keycode == XK_Down)
        move_player(game, 0, 1);
    else if (keycode == XK_a || keycode == XK_A || keycode == XK_Left)
        move_player(game, -1, 0);
    else if (keycode == XK_d || keycode == XK_D || keycode == XK_Right)
        move_player(game, 1, 0);
    return (0);
}

static int  handle_close(void *param)
{
    t_game  *game;

    game = (t_game *)param;
    request_close(game, "Game closed.\n");
    return (0);
}

int sl_setup_graphics(t_game *game)
{
    game->mlx = NULL;
    game->win = NULL;
    game->finished = 0;
    game->steps = 0;
    game->remaining = game->map.collectibles;
    game->assets = (t_assets){0};
    game->mlx = mlx_init();
    if (!game->mlx)
        return (-1);
    if (!load_assets(game))
    {
        sl_destroy_graphics(game);
        return (-1);
    }
    game->win = mlx_new_window(game->mlx,
            (int)(game->map.width * game->tile_size),
            (int)(game->map.height * game->tile_size),
            "so_long");
    if (!game->win)
    {
        sl_destroy_graphics(game);
        return (-1);
    }
    render_game(game);
    return (0);
}

void    sl_game_loop(t_game *game)
{
    if (!game->mlx || !game->win)
        return ;
    mlx_hook(game->win, 17, 0, handle_close, game);
    mlx_hook(game->win, 2, 1L << 0, handle_key, game);
    mlx_loop(game->mlx);
}

void    sl_destroy_graphics(t_game *game)
{
    if (!game)
        return ;
    if (game->mlx && game->win)
        mlx_destroy_window(game->mlx, game->win);
    unload_assets(game);
    if (game->mlx)
        mlx_destroy_display(game->mlx);
    if (game->mlx)
        free(game->mlx);
    game->mlx = NULL;
    game->win = NULL;
    game->finished = 1;
    game->tile_size = 0;
    game->assets = (t_assets){0};
}
