#ifndef BSQ_H
#define BSQ_H

#include <stdlib.h>

#define BUFFER_SIZE 4096
#define INITIAL_CAPACITY 1024

typedef struct s_map_config {
    int     row_count;
    char    empty_char;
    char    obstacle_char;
    char    full_char;
} t_map_config;

typedef struct s_map {
    char            **grid;
    int             rows;
    int             cols;
    t_map_config    config;
} t_map;

typedef struct s_square {
    int row;
    int col;
    int size;
} t_square;

/* map_parse.c - Map parsing functions */
t_map   *map_parse_from_file(const char *filename);
t_map   *map_parse_from_stdin(void);

/* map_validate.c - Map validation */
int     map_validate(t_map *map);

/* map_utils.c - Map utility functions */
t_map   *map_create(void);
void    map_free(t_map *map);
void    map_print(t_map *map);

/* solver.c - BSQ solving algorithm */
t_square    solve_bsq(t_map *map);
void        apply_solution(t_map *map, t_square *square);

/* io_utils.c - I/O utility functions */
char    *read_file_content(const char *filename);
char    *read_stdin_content(void);
void    print_error(void);

/* string_utils.c - String utility functions */
int     str_len(const char *s);
int     str_to_int(const char *s, int *end_pos);
char    **split_lines(char *content, int *line_count);
void    free_lines(char **lines, int count);

#endif
