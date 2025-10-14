#ifndef SO_LONG_H
#define SO_LONG_H

#include <stddef.h>

typedef struct s_map
{
    char    **grid;
    size_t  width;
    size_t  height;
    size_t  collectibles;
    size_t  exits;
    size_t  players;
    size_t  player_x;
    size_t  player_y;
}   t_map;

typedef struct s_texture
{
    void    *img;
    int     width;
    int     height;
}   t_texture;

typedef struct s_assets
{
    t_texture   wall;
    t_texture   floor;
    t_texture   player;
    t_texture   collectible;
    t_texture   exit_closed;
    t_texture   exit_open;
}   t_assets;

typedef struct s_game
{
    t_map   map;
    void    *mlx;
    void    *win;
    int     tile_size;
    size_t  steps;
    size_t  remaining;
    int     finished;
    t_assets    assets;
}   t_game;

int     sl_load_map(const char *path, t_map *map);
void    sl_free_map(t_map *map);
int     sl_validate_map(t_map *map);
void    sl_print_map_info(const t_map *map);
int     sl_setup_graphics(t_game *game);
void    sl_game_loop(t_game *game);
void    sl_destroy_graphics(t_game *game);

size_t  sl_strlen(const char *s);
char    *sl_strdup(const char *s);
char    *sl_strjoin(char const *s1, char const *s2);
char    *sl_substr(const char *s, size_t start, size_t len);
char    **sl_split_lines(const char *s);
void    sl_free_split(char **split);
void    sl_putstr_fd(const char *s, int fd);
void    sl_putnbr_fd(size_t n, int fd);

#endif
