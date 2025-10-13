#include "pipex.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

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

static int  init_pipex(t_pipex *px, char **argv, char **envp)
{
    char    **paths;
    char    *path_env;

    px->infile = argv[1];
    px->cmd1 = px_split_cmd(argv[2]);
    px->cmd2 = px_split_cmd(argv[3]);
    px->outfile = argv[4];
    px->envp = envp;
    if (!px->cmd1 || !px->cmd1[0] || !px->cmd2 || !px->cmd2[0])
    {
        fprintf(stderr, "pipex: invalid command\n");
        return (-1);
    }
    path_env = find_env(envp, "PATH");
    paths = px_split_path(path_env);
    px->cmd1_path = px_find_command(paths, px->cmd1[0]);
    px->cmd2_path = px_find_command(paths, px->cmd2[0]);
    px_free_split(paths);
    if (!px->cmd1_path || !px->cmd2_path)
    {
        if (!px->cmd1_path)
            fprintf(stderr, "pipex: command not found: %s\n", px->cmd1[0]);
        if (!px->cmd2_path)
            fprintf(stderr, "pipex: command not found: %s\n", px->cmd2[0]);
        return (-1);
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

static int  run_pipex(t_pipex *px)
{
    int     pipefd[2];
    pid_t   pid1;
    pid_t   pid2;
    int     status = 0;
    int     infile;
    int     outfile;

    infile = open(px->infile, O_RDONLY);
    if (infile == -1)
    {
        px_perror(px->infile);
        status = -1;
    }
    outfile = open(px->outfile, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (outfile == -1)
    {
        px_perror(px->outfile);
        status = -1;
    }
    if (pipe(pipefd) == -1)
    {
        px_perror("pipe");
        return (-1);
    }
    pid1 = fork();
    if (pid1 == -1)
    {
        px_perror("fork");
        return (-1);
    }
    if (pid1 == 0)
    {
        close(pipefd[0]);
        if (infile == -1)
            exit(EXIT_FAILURE);
        exec_child(infile, pipefd[1], px->cmd1_path, px->cmd1, px->envp);
    }
    pid2 = fork();
    if (pid2 == -1)
    {
        px_perror("fork");
        return (-1);
    }
    if (pid2 == 0)
    {
        close(pipefd[1]);
        if (outfile == -1)
            exit(EXIT_FAILURE);
        exec_child(pipefd[0], outfile, px->cmd2_path, px->cmd2, px->envp);
    }
    close(pipefd[0]);
    close(pipefd[1]);
    if (infile != -1)
        close(infile);
    if (outfile != -1)
        close(outfile);
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);
    return (status);
}

int main(int argc, char **argv, char **envp)
{
    t_pipex px;
    int     status;

    if (argc != 5)
    {
        fprintf(stderr, "Usage: %s infile \"cmd1\" \"cmd2\" outfile\n", argv[0]);
        return (EXIT_FAILURE);
    }
    if (init_pipex(&px, argv, envp) == -1)
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
