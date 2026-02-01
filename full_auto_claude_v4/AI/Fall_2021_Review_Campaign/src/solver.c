#include "bsq.h"

static int min_of_three(int a, int b, int c)
{
    int min;

    min = a;
    if (b < min)
        min = b;
    if (c < min)
        min = c;
    return (min);
}

static int **allocate_dp_table(int rows, int cols)
{
    int **dp;
    int i;

    dp = malloc(sizeof(int *) * rows);
    if (!dp)
        return (NULL);
    i = 0;
    while (i < rows)
    {
        dp[i] = malloc(sizeof(int) * cols);
        if (!dp[i])
        {
            while (--i >= 0)
                free(dp[i]);
            free(dp);
            return (NULL);
        }
        i++;
    }
    return (dp);
}

static void free_dp_table(int **dp, int rows)
{
    int i;

    if (!dp)
        return;
    i = 0;
    while (i < rows)
    {
        free(dp[i]);
        i++;
    }
    free(dp);
}

static int compute_cell_value(int **dp, int row, int col, int is_empty)
{
    if (!is_empty)
        return (0);
    if (row == 0 || col == 0)
        return (1);
    return (min_of_three(dp[row - 1][col], dp[row][col - 1],
                         dp[row - 1][col - 1]) + 1);
}

static void update_best_square(t_square *best, int row, int col, int size)
{
    if (size > best->size)
    {
        best->row = row;
        best->col = col;
        best->size = size;
    }
}

t_square solve_bsq(t_map *map)
{
    int         **dp;
    t_square    best;
    int         row;
    int         col;
    int         is_empty;

    best.row = 0;
    best.col = 0;
    best.size = 0;
    dp = allocate_dp_table(map->rows, map->cols);
    if (!dp)
        return (best);
    row = 0;
    while (row < map->rows)
    {
        col = 0;
        while (col < map->cols)
        {
            is_empty = (map->grid[row][col] == map->config.empty_char);
            dp[row][col] = compute_cell_value(dp, row, col, is_empty);
            update_best_square(&best, row, col, dp[row][col]);
            col++;
        }
        row++;
    }
    free_dp_table(dp, map->rows);
    return (best);
}

void apply_solution(t_map *map, t_square *square)
{
    int start_row;
    int start_col;
    int row;
    int col;

    if (square->size == 0)
        return;
    start_row = square->row - square->size + 1;
    start_col = square->col - square->size + 1;
    row = start_row;
    while (row <= square->row)
    {
        col = start_col;
        while (col <= square->col)
        {
            map->grid[row][col] = map->config.full_char;
            col++;
        }
        row++;
    }
}
