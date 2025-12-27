#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

static void die(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

static void ensure_dir(const char *path)
{
    struct stat st;
    if (stat(path, &st) == 0)
    {
        if (!S_ISDIR(st.st_mode))
        {
            fprintf(stderr, "ft_shield: %s exists and is not a directory\n", path);
            exit(EXIT_FAILURE);
        }
        return;
    }
    if (mkdir(path, 0700) != 0)
        die("ft_shield: mkdir");
}

static ssize_t copy_file(const char *src, const char *dst)
{
    int in = open(src, O_RDONLY);
    if (in < 0)
        return -1;
    int out = open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0700);
    if (out < 0)
    {
        close(in);
        return -1;
    }
    char buf[4096];
    ssize_t total = 0;
    ssize_t n;
    while ((n = read(in, buf, sizeof(buf))) > 0)
    {
        ssize_t w = write(out, buf, n);
        if (w != n)
        {
            close(in);
            close(out);
            return -1;
        }
        total += w;
    }
    close(in);
    close(out);
    return total;
}

static void append_log(const char *log_path, const char *command)
{
    FILE *f = fopen(log_path, "a");
    if (!f)
        return;
    time_t now = time(NULL);
    struct tm *tm = localtime(&now);
    char ts[64];
    if (tm)
        strftime(ts, sizeof(ts), "%Y-%m-%d %H:%M:%S", tm);
    else
        strncpy(ts, "unknown", sizeof(ts));
    fprintf(f, "[FT_SHIELD_LOG] %s | pid=%d | cmd=\"%s\" | user=%s | host=%s\n",
            ts, getpid(), command, getenv("USER") ? getenv("USER") : "unknown",
            getenv("HOSTNAME") ? getenv("HOSTNAME") : "unknown");
    fclose(f);
}

static const char *get_self_path(char *buf, size_t size)
{
    ssize_t n = readlink("/proc/self/exe", buf, size - 1);
    if (n < 0 || (size_t)n >= size)
        return NULL;
    buf[n] = '\0';
    return buf;
}

static void ensure_line_in_file(const char *path, const char *line)
{
    FILE *f = fopen(path, "r");
    if (f)
    {
        char buf[4096];
        while (fgets(buf, sizeof(buf), f))
        {
            if (strstr(buf, line))
            {
                fclose(f);
                return;
            }
        }
        fclose(f);
    }
    f = fopen(path, "a");
    if (!f)
        return;
    fprintf(f, "%s\n", line);
    fclose(f);
}

int main(int argc, char **argv)
{
    const char *cmd = "echo Nothing to see here.";
    const char *install_hook = NULL;
    if (argc == 3 && strcmp(argv[1], "-c") == 0)
        cmd = argv[2];
    else if (argc == 3 && strcmp(argv[1], "-i") == 0)
        install_hook = argv[2];
    else if (argc == 5 && strcmp(argv[1], "-c") == 0 && strcmp(argv[3], "-i") == 0)
    {
        cmd = argv[2];
        install_hook = argv[4];
    }
    else if (argc != 1)
    {
        fprintf(stderr, "usage: %s [-c \"command\"] [-i install_cmd]\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *home = getenv("HOME");
    if (!home)
    {
        fprintf(stderr, "ft_shield: HOME not set\n");
        return EXIT_FAILURE;
    }
    char base[PATH_MAX];
    if (snprintf(base, sizeof(base), "%s/.ft_shield", home) >= (int)sizeof(base))
    {
        fprintf(stderr, "ft_shield: path too long\n");
        return EXIT_FAILURE;
    }
    ensure_dir(base);

    char self[PATH_MAX];
    char target[PATH_MAX];
    if (get_self_path(self, sizeof(self)))
    {
        if (snprintf(target, sizeof(target), "%s/ft_shield.bin", base) < (int)sizeof(target))
            copy_file(self, target); /* best effort, ignore failure */
    }

    char log_path[PATH_MAX];
    if (snprintf(log_path, sizeof(log_path), "%s/log.txt", base) < (int)sizeof(log_path))
        append_log(log_path, cmd);

    if (install_hook)
    {
        char rc_path[PATH_MAX];
        if (snprintf(rc_path, sizeof(rc_path), "%s/.bashrc", home) < (int)sizeof(rc_path))
        {
            ensure_line_in_file(rc_path, install_hook);
        }
    }

    int rc = system(cmd);
    if (rc == -1)
    {
        perror("ft_shield: system");
        return EXIT_FAILURE;
    }
    if (WIFEXITED(rc))
        return WEXITSTATUS(rc);
    return EXIT_FAILURE;
}
