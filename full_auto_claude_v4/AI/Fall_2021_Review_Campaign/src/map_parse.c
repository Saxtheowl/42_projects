#include "bsq.h"

static int parse_header(const char *header, t_map_config *config)
{
    int header_len;
    int end_pos;

    header_len = str_len(header);
    if (header_len < 4)
        return (0);
    config->row_count = str_to_int(header, &end_pos);
    if (config->row_count <= 0 || end_pos + 3 != header_len)
        return (0);
    config->empty_char = header[end_pos];
    config->obstacle_char = header[end_pos + 1];
    config->full_char = header[end_pos + 2];
    if (config->empty_char == config->obstacle_char ||
        config->empty_char == config->full_char ||
        config->obstacle_char == config->full_char)
        return (0);
    return (1);
}

static int fill_grid(t_map *map, char **lines, int line_count)
{
    int i;

    if (line_count != map->config.row_count + 1)
        return (0);
    map->rows = map->config.row_count;
    map->grid = malloc(sizeof(char *) * map->rows);
    if (!map->grid)
        return (0);
    i = 0;
    while (i < map->rows)
    {
        map->grid[i] = lines[i + 1];
        lines[i + 1] = NULL;
        i++;
    }
    if (map->rows > 0)
        map->cols = str_len(map->grid[0]);
    else
        map->cols = 0;
    return (1);
}

static t_map *parse_content(char *content)
{
    t_map   *map;
    char    **lines;
    int     line_count;

    if (!content || !*content)
        return (NULL);
    lines = split_lines(content, &line_count);
    if (!lines || line_count < 2)
    {
        free_lines(lines, line_count);
        return (NULL);
    }
    map = map_create();
    if (!map)
    {
        free_lines(lines, line_count);
        return (NULL);
    }
    if (!parse_header(lines[0], &map->config) ||
        !fill_grid(map, lines, line_count))
    {
        free_lines(lines, line_count);
        map_free(map);
        return (NULL);
    }
    free_lines(lines, line_count);
    return (map);
}

t_map *map_parse_from_file(const char *filename)
{
    char    *content;
    t_map   *map;

    content = read_file_content(filename);
    if (!content)
        return (NULL);
    map = parse_content(content);
    free(content);
    return (map);
}

t_map *map_parse_from_stdin(void)
{
    char    *content;
    t_map   *map;

    content = read_stdin_content();
    if (!content)
        return (NULL);
    map = parse_content(content);
    free(content);
    return (map);
}
