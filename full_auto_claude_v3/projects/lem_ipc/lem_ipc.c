/* ************************************************************************** */
/*                                                                            */
/*   lem_ipc - Inter-Process Communication Game                              */
/*   Shared memory and semaphore-based multiplayer game                       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/types.h>
#include <signal.h>
#include <time.h>

#define MAP_WIDTH    20
#define MAP_HEIGHT   20
#define MAX_PLAYERS  8
#define SHM_KEY      0x42424242
#define SEM_KEY      0x42424243

/* Tile types */
#define TILE_EMPTY   0
#define TILE_WALL    1
#define TILE_PLAYER  2

/* Player states */
#define STATE_INACTIVE  0
#define STATE_ACTIVE    1
#define STATE_DEAD      2

typedef struct s_player
{
    int     id;
    int     team;
    int     x;
    int     y;
    int     state;
    int     kills;
    pid_t   pid;
}   t_player;

typedef struct s_game
{
    int         map[MAP_HEIGHT][MAP_WIDTH];
    t_player    players[MAX_PLAYERS];
    int         player_count;
    int         game_running;
    int         turn;
}   t_game;

/* Global variables */
static int      g_shm_id = -1;
static int      g_sem_id = -1;
static t_game   *g_game = NULL;
static int      g_my_id = -1;

/* ============================================================ */
/* Semaphore Operations                                          */
/* ============================================================ */

union semun {
    int             val;
    struct semid_ds *buf;
    unsigned short  *array;
};

int     sem_init_or_get(void)
{
    union semun arg;
    int         sem_id;

    sem_id = semget(SEM_KEY, 1, IPC_CREAT | IPC_EXCL | 0666);
    if (sem_id != -1)
    {
        /* Created new semaphore, initialize it */
        arg.val = 1;
        if (semctl(sem_id, 0, SETVAL, arg) == -1)
        {
            perror("semctl");
            return (-1);
        }
    }
    else
    {
        /* Get existing semaphore */
        sem_id = semget(SEM_KEY, 1, 0666);
    }
    return (sem_id);
}

void    sem_lock(void)
{
    struct sembuf op;

    op.sem_num = 0;
    op.sem_op = -1;
    op.sem_flg = 0;
    semop(g_sem_id, &op, 1);
}

void    sem_unlock(void)
{
    struct sembuf op;

    op.sem_num = 0;
    op.sem_op = 1;
    op.sem_flg = 0;
    semop(g_sem_id, &op, 1);
}

/* ============================================================ */
/* Shared Memory Operations                                      */
/* ============================================================ */

t_game  *shm_init_or_get(void)
{
    int     shm_id;
    t_game  *game;
    int     created;

    created = 0;
    shm_id = shmget(SHM_KEY, sizeof(t_game), IPC_CREAT | IPC_EXCL | 0666);
    if (shm_id != -1)
    {
        created = 1;
    }
    else
    {
        shm_id = shmget(SHM_KEY, sizeof(t_game), 0666);
    }

    if (shm_id == -1)
    {
        perror("shmget");
        return (NULL);
    }

    g_shm_id = shm_id;
    game = shmat(shm_id, NULL, 0);
    if (game == (void *)-1)
    {
        perror("shmat");
        return (NULL);
    }

    if (created)
    {
        /* Initialize game state */
        memset(game, 0, sizeof(t_game));
        game->game_running = 1;
        game->turn = 0;

        /* Initialize map with walls on borders */
        for (int y = 0; y < MAP_HEIGHT; y++)
        {
            for (int x = 0; x < MAP_WIDTH; x++)
            {
                if (x == 0 || x == MAP_WIDTH - 1 ||
                    y == 0 || y == MAP_HEIGHT - 1)
                    game->map[y][x] = TILE_WALL;
                else
                    game->map[y][x] = TILE_EMPTY;
            }
        }
        printf("Game initialized (new shared memory)\n");
    }
    else
    {
        printf("Joined existing game\n");
    }

    return (game);
}

/* ============================================================ */
/* Game Logic                                                    */
/* ============================================================ */

int     find_empty_slot(void)
{
    for (int i = 0; i < MAX_PLAYERS; i++)
    {
        if (g_game->players[i].state == STATE_INACTIVE)
            return (i);
    }
    return (-1);
}

int     join_game(int team)
{
    int     slot;
    int     x, y;

    sem_lock();

    slot = find_empty_slot();
    if (slot == -1)
    {
        sem_unlock();
        printf("Game is full!\n");
        return (-1);
    }

    /* Find random empty position */
    do {
        x = 1 + rand() % (MAP_WIDTH - 2);
        y = 1 + rand() % (MAP_HEIGHT - 2);
    } while (g_game->map[y][x] != TILE_EMPTY);

    /* Initialize player */
    g_game->players[slot].id = slot;
    g_game->players[slot].team = team;
    g_game->players[slot].x = x;
    g_game->players[slot].y = y;
    g_game->players[slot].state = STATE_ACTIVE;
    g_game->players[slot].kills = 0;
    g_game->players[slot].pid = getpid();

    /* Place on map */
    g_game->map[y][x] = TILE_PLAYER;
    g_game->player_count++;

    g_my_id = slot;

    sem_unlock();

    printf("Joined game as player %d (team %d) at (%d, %d)\n",
           slot, team, x, y);
    return (slot);
}

void    leave_game(void)
{
    if (g_my_id < 0 || !g_game)
        return;

    sem_lock();

    t_player *p = &g_game->players[g_my_id];
    if (p->state == STATE_ACTIVE)
    {
        g_game->map[p->y][p->x] = TILE_EMPTY;
        p->state = STATE_INACTIVE;
        g_game->player_count--;
    }

    sem_unlock();
    printf("Left game\n");
}

int     can_move(int x, int y)
{
    if (x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT)
        return (0);
    return (g_game->map[y][x] != TILE_WALL);
}

void    move_player(int dx, int dy)
{
    if (g_my_id < 0)
        return;

    sem_lock();

    t_player *p = &g_game->players[g_my_id];
    if (p->state != STATE_ACTIVE)
    {
        sem_unlock();
        return;
    }

    int new_x = p->x + dx;
    int new_y = p->y + dy;

    if (!can_move(new_x, new_y))
    {
        sem_unlock();
        return;
    }

    /* Check for combat */
    if (g_game->map[new_y][new_x] == TILE_PLAYER)
    {
        /* Find enemy player */
        for (int i = 0; i < MAX_PLAYERS; i++)
        {
            if (i == g_my_id)
                continue;
            if (g_game->players[i].x == new_x &&
                g_game->players[i].y == new_y &&
                g_game->players[i].state == STATE_ACTIVE)
            {
                /* Combat! */
                if (g_game->players[i].team != p->team)
                {
                    /* Kill enemy */
                    g_game->players[i].state = STATE_DEAD;
                    g_game->map[new_y][new_x] = TILE_EMPTY;
                    p->kills++;
                    printf("Killed player %d!\n", i);
                }
                break;
            }
        }
    }

    /* Move */
    if (g_game->map[new_y][new_x] == TILE_EMPTY)
    {
        g_game->map[p->y][p->x] = TILE_EMPTY;
        p->x = new_x;
        p->y = new_y;
        g_game->map[new_y][new_x] = TILE_PLAYER;
    }

    sem_unlock();
}

void    print_map(void)
{
    printf("\033[H\033[J");  /* Clear screen */
    printf("=== Lem-IPC Game (Turn %d) ===\n\n", g_game->turn);

    for (int y = 0; y < MAP_HEIGHT; y++)
    {
        for (int x = 0; x < MAP_WIDTH; x++)
        {
            switch (g_game->map[y][x])
            {
                case TILE_WALL:
                    printf("#");
                    break;
                case TILE_PLAYER:
                    /* Find player at this position */
                    for (int i = 0; i < MAX_PLAYERS; i++)
                    {
                        if (g_game->players[i].x == x &&
                            g_game->players[i].y == y &&
                            g_game->players[i].state == STATE_ACTIVE)
                        {
                            if (i == g_my_id)
                                printf("\033[1;32m@\033[0m");  /* Green for self */
                            else if (g_game->players[i].team == g_game->players[g_my_id].team)
                                printf("\033[1;34m%d\033[0m", g_game->players[i].team);  /* Blue for ally */
                            else
                                printf("\033[1;31m%d\033[0m", g_game->players[i].team);  /* Red for enemy */
                            break;
                        }
                    }
                    break;
                default:
                    printf(".");
                    break;
            }
        }
        printf("\n");
    }

    printf("\nPlayers:\n");
    for (int i = 0; i < MAX_PLAYERS; i++)
    {
        if (g_game->players[i].state == STATE_ACTIVE)
        {
            printf("  [%d] Team %d at (%d,%d) - %d kills%s\n",
                   i,
                   g_game->players[i].team,
                   g_game->players[i].x,
                   g_game->players[i].y,
                   g_game->players[i].kills,
                   (i == g_my_id) ? " (you)" : "");
        }
    }

    printf("\nControls: WASD to move, Q to quit\n");
}

/* ============================================================ */
/* Signal Handler                                                */
/* ============================================================ */

void    cleanup(int sig)
{
    (void)sig;
    leave_game();
    if (g_game)
        shmdt(g_game);
    exit(0);
}

/* ============================================================ */
/* Main                                                          */
/* ============================================================ */

int     main(int argc, char **argv)
{
    int     team;
    char    input;

    if (argc < 2)
    {
        printf("lem_ipc - IPC Multiplayer Game\n\n");
        printf("Usage: %s <team_number>\n", argv[0]);
        printf("\nTeam numbers: 1-4\n");
        printf("Players on the same team are allies.\n");
        printf("Move into enemies to attack them.\n");
        return (1);
    }

    team = atoi(argv[1]);
    if (team < 1 || team > 4)
    {
        printf("Team must be 1-4\n");
        return (1);
    }

    srand(time(NULL) ^ getpid());

    /* Setup IPC */
    g_sem_id = sem_init_or_get();
    if (g_sem_id == -1)
        return (1);

    g_game = shm_init_or_get();
    if (!g_game)
        return (1);

    /* Setup signal handlers */
    signal(SIGINT, cleanup);
    signal(SIGTERM, cleanup);

    /* Join game */
    if (join_game(team) == -1)
    {
        shmdt(g_game);
        return (1);
    }

    /* Game loop */
    while (g_game->game_running)
    {
        print_map();

        /* Read input with timeout */
        input = getchar();

        switch (input)
        {
            case 'w': case 'W':
                move_player(0, -1);
                break;
            case 's': case 'S':
                move_player(0, 1);
                break;
            case 'a': case 'A':
                move_player(-1, 0);
                break;
            case 'd': case 'D':
                move_player(1, 0);
                break;
            case 'q': case 'Q':
                cleanup(0);
                break;
        }

        g_game->turn++;
        usleep(50000);  /* 50ms delay */
    }

    cleanup(0);
    return (0);
}
