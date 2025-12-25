#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "config.h"
#include "args.h"
#include "log.h"

volatile sig_atomic_t running = 1;

static void handle(int sig) {
    (void)sig;
    running = 0;
}

static int ensure_log_dir(const char *path) {
    char *dir = strdup(path);
    if (!dir)
        return -1;
    char *slash = strrchr(dir, '/');
    if (slash) {
        *slash = '\0';
        if (mkdir(dir, 0755) && errno != EEXIST) {
            free(dir);
            return -1;
        }
    }
    free(dir);
    return 0;
}

static int connection_count = 0;


static void send_response(int fd, const char *message) {
    if (!message)
        return;
    size_t len = strlen(message);
    if (len > 0) {
        write(fd, message, len);
        if (message[len - 1] != '\n')
            write(fd, "\n", 1);
    } else {
        write(fd, "\n", 1);
    }
}

int main(int argc, char **argv) {
    struct sigaction sa = {0};
    sa.sa_handler = handle;
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);

    struct ft_services_args opts;
    parse_args(argc, argv, &opts);

    const char *cfg_path = opts.config_path ? : getenv("FT_SERVICES_CONF");
    if (!cfg_path)
        cfg_path = "/etc/ft_services.conf";

    struct ft_services_config cfg = {0, NULL, 0, NULL, 0};
    if (load_config(cfg_path, &cfg) != 0) {
        fprintf(stderr, "unable to load config %s\n", cfg_path);
        return 1;
    }

    if (cfg.backlog <= 0)
        cfg.backlog = 10;
    if (cfg.port <= 0)
        cfg.port = 4242;

    if (cfg.log_path && ensure_log_dir(cfg.log_path) != 0) {
        fprintf(stderr, "unable to prepare log directory %s\n", cfg.log_path);
        free_config(&cfg);
        return 1;
    }

    int log_fd = -1;
    if (cfg.log_path) {
        log_fd = open(cfg.log_path, O_WRONLY | O_CREAT | O_APPEND, 0644);
        if (log_fd >= 0) {
            log_event(log_fd, "ft_services started");
        }
    }

    const char *welcome_msg = cfg.welcome ? cfg.welcome : "ft_services says hello\n";
    const char *status_ok = "STATUS: OK\n";
    
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        fprintf(stderr, "unable to create socket: %s\n", strerror(errno));
    } else {
        int opt = 1;
        setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
        struct sockaddr_in addr = {0};
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        addr.sin_port = htons(cfg.port);
        if (bind(server_fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
            fprintf(stderr, "unable to bind port %d: %s\n", cfg.port, strerror(errno));
            close(server_fd);
            server_fd = -1;
        } else {
            if (listen(server_fd, cfg.backlog) != 0) {
                fprintf(stderr, "unable to listen: %s\n", strerror(errno));
                close(server_fd);
                server_fd = -1;
            }
        }
    }

    printf("ft_services starting on port %d, log %s\n", cfg.port, cfg.log_path ? cfg.log_path : "(none)");

    while (running) {
        if (server_fd < 0) {
            pause();
            continue;
        }
        struct sockaddr_in peer = {0};
        socklen_t peer_len = sizeof(peer);
        int client_fd = accept(server_fd, (struct sockaddr *)&peer, &peer_len);
        if (client_fd < 0) {
            if (errno == EINTR)
                continue;
            fprintf(stderr, "accept error: %s\n", strerror(errno));
            break;
        }
        char client_ip[INET_ADDRSTRLEN] = "(unknown)";
        inet_ntop(AF_INET, &peer.sin_addr, client_ip, sizeof(client_ip));
        char event[128];
        snprintf(event, sizeof(event), "connection from %s", client_ip);
        if (log_fd >= 0)
            log_event(log_fd, event);
        connection_count++;
        const char *response = welcome_msg;
        char overload_msg[64];
        if (cfg.max_connections > 0 && connection_count > cfg.max_connections) {
            int len = snprintf(overload_msg, sizeof(overload_msg), "overloaded: %d", connection_count);
            response = len > 0 ? overload_msg : "overloaded";
            if (log_fd >= 0)
                log_event(log_fd, "connection limit reached");
        }
        char buffer[128];
        ssize_t received = recv(client_fd, buffer, sizeof(buffer) - 1, MSG_DONTWAIT);
        if (received > 0) {
            buffer[received] = '\0';
            char *nl = strpbrk(buffer, "\r\n");
            if (nl)
                *nl = '\0';
            if (strcmp(buffer, "STATUS") == 0)
                response = status_ok;
            if (strcmp(buffer, "COUNT") == 0) {
                static char count_msg[64];
                snprintf(count_msg, sizeof(count_msg), "connections: %d", connection_count);
                response = count_msg;
            }
        }
        if (log_fd >= 0 && response == status_ok)
            log_event(log_fd, "status check");
        send_response(client_fd, response);
        close(client_fd);
    }

    printf("ft_services shutting down\n");
    if (log_fd >= 0) {
        log_event(log_fd, "ft_services stopping");
        close(log_fd);
    }
    if (server_fd >= 0)
        close(server_fd);
    free_config(&cfg);
    return 0;
}
