#include "pipex.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/uio.h>

static char *find_env(char **envp, const char *key)
{
    size_t len;

    len = px_strlen(key);
    while (envp && *envp)
    {
        if (px_strncmp(*envp, key, len) == 0 && (*envp)[len] == '=')
            return (*envp + len + 1);
        envp++;
    }
    return (NULL);
}

static int  init_pipex(t_pipex *px, int argc, char **argv, char **envp)
{
    char    **paths;
    char    *path_env;
    int     start;

    px->here_doc = (px_strncmp(argv[1], "here_doc", 9) == 0);
    if (px->here_doc)
    {
        px->limiter = argv[2];
        px->infile = NULL;
        px->outfile = argv[argc - 1];
        start = 3;
    }
    else
    {
        px->limiter = NULL;
        px->infile = argv[1];
        px->outfile = argv[argc - 1];
        start = 2;
    }
    px->cmd_count = argc - start - 1;
    if (px->cmd_count < 2)
    {
        fprintf(stderr, "pipex: need at least two commands\n");
        return (-1);
    }
    px->cmds = calloc(px->cmd_count, sizeof(t_cmd));
    if (!px->cmds)
        return (-1);
    for (int i = 0; i < px->cmd_count; ++i)
    {
        px->cmds[i].argv = px_split_cmd(argv[start + i]);
        if (!px->cmds[i].argv || !px->cmds[i].argv[0])
        {
            fprintf(stderr, "pipex: invalid command\n");
            return (-1);
        }
    }
    px->envp = envp;
    path_env = find_env(envp, "PATH");
    paths = px_split_path(path_env);
    for (int i = 0; i < px->cmd_count; ++i)
        px->cmds[i].path = px_find_command(paths, px->cmds[i].argv[0]);
    px_free_split(paths);
    for (int i = 0; i < px->cmd_count; ++i)
    {
        if (!px->cmds[i].path)
        {
            fprintf(stderr, "pipex: command not found: %s\n", px->cmds[i].argv[0]);
            return (-1);
        }
    }
    return (0);
}

static void exec_child(int infile, int outfile, char *cmd_path, char **cmd, char **envp)
{
    if (dup2(infile, STDIN_FILENO) == -1 || dup2(outfile, STDOUT_FILENO) == -1)
    {
        px_perror("dup2");
        exit(EXIT_FAILURE);
    }
    if (infile != STDIN_FILENO)
        close(infile);
    if (outfile != STDOUT_FILENO)
        close(outfile);
    execve(cmd_path, cmd, envp);
    px_perror(cmd_path);
    exit(EXIT_FAILURE);
}

static int  open_heredoc(const char *limiter)
{
    int     pipefd[2];
    char    *line;
    size_t  cap = 0;
    ssize_t nread;

    if (pipe(pipefd) == -1)
    {
        px_perror("pipe");
        return (-1);
    }
    line = NULL;
    while (1)
    {
        nread = getline(&line, &cap, stdin);
        if (nread == -1)
            break;
        if (nread > 0 && line[nread - 1] == '\n')
            line[nread - 1] = '\0';
        if (px_strncmp(line, limiter, px_strlen(limiter) + 1) == 0)
            break;
        write(pipefd[1], line, px_strlen(line));
        write(pipefd[1], "\n", 1);
    }
    free(line);
    close(pipefd[1]);
    return (pipefd[0]);
}

static int  run_pipex(t_pipex *px)
{
    int     prev_read = -1;
    int     status = 0;
    pid_t   *pids = calloc(px->cmd_count, sizeof(pid_t));
    if (!pids)
        return (-1);
    for (int i = 0; i < px->cmd_count; ++i)
    {
        int pipefd[2] = {-1, -1};
        int infile = -1;
        int outfile = -1;
        if (i < px->cmd_count - 1 && pipe(pipefd) == -1)
        {
            px_perror("pipe");
            return (-1);
        }
        if (i == 0)
        {
            if (px->here_doc)
                infile = open_heredoc(px->limiter);
            else
                infile = open(px->infile, O_RDONLY);
            if (infile == -1 && !px->here_doc)
                px_perror(px->infile);
        }
        else
            infile = prev_read;

        if (i == px->cmd_count - 1)
        {
            outfile = open(px->outfile, O_CREAT | O_WRONLY | (px->here_doc ? O_APPEND : O_TRUNC), 0644);
            if (outfile == -1)
            {
                px_perror(px->outfile);
                status = -1;
            }
        }
        else
            outfile = pipefd[1];

        pid_t pid = fork();
        if (pid == -1)
        {
            px_perror("fork");
            free(pids);
            return (-1);
        }
        pids[i] = pid;
        if (pid == 0)
        {
            if (pipefd[0] != -1)
                close(pipefd[0]);
            if (prev_read != -1 && infile != prev_read)
                close(prev_read);
            if (infile == -1)
                exit(EXIT_FAILURE);
            exec_child(infile, outfile, px->cmds[i].path, px->cmds[i].argv, px->envp);
        }
        if (infile != -1 && infile != prev_read)
            close(infile);
        if (pipefd[1] != -1)
            close(pipefd[1]);
        if (outfile != -1 && outfile != pipefd[1])
            close(outfile);
        if (prev_read != -1)
            close(prev_read);
        prev_read = pipefd[0];
    }
    int last_status = 0;
    for (int i = 0; i < px->cmd_count; ++i)
    {
        int wstatus = 0;
        waitpid(pids[i], &wstatus, 0);
        if (i == px->cmd_count - 1)
        {
            if (WIFEXITED(wstatus))
                last_status = WEXITSTATUS(wstatus);
            else if (WIFSIGNALED(wstatus))
                last_status = 128 + WTERMSIG(wstatus);
            else
                last_status = 1;
        }
    }
    free(pids);
    if (prev_read != -1)
        close(prev_read);
    return (status == -1 ? -1 : last_status);
}

int main(int argc, char **argv, char **envp)
{
    t_pipex px;
    int     status;

    memset(&px, 0, sizeof(t_pipex));
    if ((argc < 5) || (px_strncmp(argv[1], "here_doc", 9) == 0 && argc < 6))
    {
        fprintf(stderr, "Usage: %s infile \"cmd1\" \"cmd2\" outfile\n", argv[0]);
        fprintf(stderr, "   or: %s here_doc LIMITER \"cmd1\" \"cmd2\" outfile\n", argv[0]);
        return (EXIT_FAILURE);
    }
    if (init_pipex(&px, argc, argv, envp) == -1)
    {
        px_cleanup(&px);
        return (EXIT_FAILURE);
    }
    status = run_pipex(&px);
    px_cleanup(&px);
    if (status == -1)
        return (EXIT_FAILURE);
    return (EXIT_SUCCESS);
}
