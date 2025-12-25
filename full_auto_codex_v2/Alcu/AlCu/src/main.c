#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 64

static int	*g_initial_heaps = NULL;
static int	g_heap_count = 0;
static signed char **g_memo = NULL;

static void	print_error(void)
{
	fprintf(stderr, "ERROR\n");
}

static int	parse_heaps(FILE *in, int **out_heaps, int *out_count)
{
	char buf[MAX_LINE];
	int cap = 8;
	int count = 0;
	int *heaps = malloc(sizeof(int) * cap);
	if (!heaps)
		return 0;
	while (fgets(buf, sizeof(buf), in))
	{
		if (buf[0] == '\n' || buf[0] == '\r' || buf[0] == '\0')
			break;
		char *end = NULL;
		long v = strtol(buf, &end, 10);
		if (end == buf || (*end && *end != '\n' && *end != '\r') || v < 1 || v > 10000)
		{
			free(heaps);
			return 0;
		}
		if (count == cap)
		{
			cap *= 2;
			int *tmp = realloc(heaps, sizeof(int) * cap);
			if (!tmp)
			{
				free(heaps);
				return 0;
			}
			heaps = tmp;
		}
		heaps[count++] = (int)v;
	}
	if (count == 0)
	{
		free(heaps);
		return 0;
	}
	*out_heaps = heaps;
	*out_count = count;
	g_heap_count = count;
	return 1;
}

static void	print_board(const int *heaps, int count)
{
	for (int i = 0; i < count; ++i)
	{
		for (int j = 0; j < heaps[i]; ++j)
			putchar('|');
		putchar('\n');
	}
}

static int	is_game_over(int count)
{
	return count == 0;
}

static int	is_winning(int idx, int size)
{
	if (size <= 0)
		return 0;
	if (g_memo[idx][size] != -1)
		return g_memo[idx][size];
	for (int take = 1; take <= 3 && take <= size; ++take)
	{
		if (size - take == 0)
		{
			if (idx == 0)
				continue; /* taking last of last heap loses */
			if (!is_winning(idx - 1, g_initial_heaps[idx - 1]))
				return (g_memo[idx][size] = 1);
		}
		else
		{
			if (!is_winning(idx, size - take))
				return (g_memo[idx][size] = 1);
		}
	}
	return (g_memo[idx][size] = 0);
}

static int	ai_move(int *heaps, int *count)
{
	int idx = *count - 1;
	int best = 1;
	for (int take = 1; take <= 3 && take <= heaps[idx]; ++take)
	{
		int win;
		if (heaps[idx] - take == 0)
		{
			if (idx == 0)
				continue;
			win = !is_winning(idx - 1, g_initial_heaps[idx - 1]);
		}
		else
			win = !is_winning(idx, heaps[idx] - take);
		if (win)
		{
			best = take;
			break;
		}
	}
	heaps[idx] -= best;
	printf("AI removed %d item(s)\n", best);
	if (heaps[idx] == 0)
		(*count)--;
	return best;
}

static int	player_move(int *heaps, int *count)
{
	int idx = *count - 1;
	int take = 0;
	int readcount = 0;
	while (1)
	{
		printf("Your turn: ");
		readcount = scanf("%d", &take);
		if (readcount != 1)
		{
			int c;
			while ((c = getchar()) != '\n' && c != EOF)
				;
			if (readcount == EOF)
				return -2; /* player quits (EOF) */
			printf("Invalid input (not a number). Try again.\n");
			continue;
		}
		if (take >= 1 && take <= 3 && take <= heaps[idx])
			break;
		printf("Invalid input (1-3 and <= remaining). Try again.\n");
	}
	heaps[idx] -= take;
	if (heaps[idx] == 0)
		(*count)--;
	return take;
}

int	main(int argc, char **argv)
{
	FILE *in = stdin;
	if (argc == 2)
	{
		in = fopen(argv[1], "r");
		if (!in)
		{
			print_error();
			return 84;
		}
	}

	int *heaps = NULL;
	int count = 0;
	if (!parse_heaps(in, &heaps, &count))
	{
		print_error();
		if (in != stdin)
			fclose(in);
		return 84;
	}
	if (in != stdin)
		fclose(in);

	g_initial_heaps = malloc(sizeof(int) * count);
	if (!g_initial_heaps)
	{
		print_error();
		free(heaps);
		return 84;
	}
	memcpy(g_initial_heaps, heaps, sizeof(int) * count);
	g_memo = calloc(count, sizeof(signed char *));
	if (!g_memo)
	{
		print_error();
		free(g_initial_heaps);
		free(heaps);
		return 84;
	}
	for (int i = 0; i < count; ++i)
	{
		g_memo[i] = malloc((g_initial_heaps[i] + 1) * sizeof(signed char));
		if (!g_memo[i])
		{
			print_error();
			for (int j = 0; j < i; ++j)
				free(g_memo[j]);
			free(g_memo);
			free(g_initial_heaps);
			free(heaps);
			return 84;
		}
		memset(g_memo[i], -1, (g_initial_heaps[i] + 1) * sizeof(signed char));
	}

	printf("Initial board:\n");
	print_board(heaps, count);

	int ai_turn = 1;
	while (!is_game_over(count))
	{
		if (ai_turn)
		{
			ai_move(heaps, &count);
			if (is_game_over(count))
			{
				printf("AI took the last item. You win!\n");
				break;
			}
		}
		else
		{
			int res = player_move(heaps, &count);
			if (res == -2)
			{
				printf("EOF received. You quit, AI wins!\n");
				break;
			}
			if (res < 0)
			{
				print_error();
				free(heaps);
				return 84;
			}
			if (is_game_over(count))
			{
				printf("You took the last item. AI wins!\n");
				break;
			}
		}
		print_board(heaps, count);
		ai_turn = !ai_turn;
	}

	free(heaps);
	for (int i = 0; i < g_heap_count; ++i)
		free(g_memo[i]);
	free(g_memo);
	free(g_initial_heaps);
	return 0;
}
