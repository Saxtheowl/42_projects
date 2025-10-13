#include "ft_strace.h"
#include "syscall_table.h"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ptrace.h>
#include <sys/procfs.h>
#include <sys/uio.h>
#include <sys/user.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef PTRACE_O_EXITKILL
# define PTRACE_O_EXITKILL 0x00100000
#endif

#ifndef NT_PRSTATUS
# define NT_PRSTATUS 1
#endif

static int  fetch_registers(pid_t pid, struct user_regs_struct *regs)
{
    struct iovec  iov;

    iov.iov_base = regs;
    iov.iov_len = sizeof(*regs);
    if (ptrace(PTRACE_GETREGSET, pid, (void *)NT_PRSTATUS, &iov) == -1)
        return (-1);
    return (0);
}

static void extract_arguments(const struct user_regs_struct *regs, const t_trace_config *cfg, unsigned long args[STRACE_MAX_ARGS])
{
    if (cfg->is_64bit)
    {
        args[0] = regs->rdi;
        args[1] = regs->rsi;
        args[2] = regs->rdx;
        args[3] = regs->r10;
        args[4] = regs->r8;
        args[5] = regs->r9;
    }
    else
    {
        args[0] = regs->rbx;
        args[1] = regs->rcx;
        args[2] = regs->rdx;
        args[3] = regs->rsi;
        args[4] = regs->rdi;
        args[5] = regs->rbp;
    }
}

static long get_syscall_number(const struct user_regs_struct *regs, const t_trace_config *cfg)
{
    (void)cfg;
    return (long)regs->orig_rax;
}

static long get_syscall_retval(const struct user_regs_struct *regs)
{
    return (long)regs->rax;
}

static void print_syscall_enter(const struct user_regs_struct *regs, const t_trace_config *cfg)
{
    unsigned long  args[STRACE_MAX_ARGS];
    const char      *name;
    long            number;
    int             index;

    number = get_syscall_number(regs, cfg);
    name = syscall_lookup_name(number, cfg->is_64bit);
    if (name == NULL)
        name = "unknown";
    extract_arguments(regs, cfg, args);
    printf("%s(", name);
    for (index = 0; index < STRACE_MAX_ARGS; ++index)
    {
        if (index > 0)
            printf(", ");
        printf("0x%lx", args[index]);
    }
    printf(")");
    fflush(stdout);
}

static void print_syscall_exit(const struct user_regs_struct *regs)
{
    long retval;

    retval = get_syscall_retval(regs);
    printf(" = 0x%lx\n", retval);
    fflush(stdout);
}

static void print_signal(int sig)
{
    const char *name;

    name = strsignal(sig);
    if (name == NULL)
        name = "?";
    printf("--- %s ---\n", name);
    fflush(stdout);
}

static int  trace_loop(pid_t child, const t_trace_config *cfg)
{
    int                         status;
    int                         in_syscall;
    struct user_regs_struct     regs;

    in_syscall = 0;
    while (1)
    {
        if (waitpid(child, &status, 0) == -1)
        {
            perror("waitpid");
            return (-1);
        }
        if (WIFEXITED(status))
        {
            if (in_syscall)
            {
                printf(" = ?\n");
                in_syscall = 0;
            }
            printf("+++ exited with %d +++\n", WEXITSTATUS(status));
            break ;
        }
        if (WIFSIGNALED(status))
        {
            if (in_syscall)
            {
                printf(" = ?\n");
                in_syscall = 0;
            }
            printf("+++ killed by signal %d (%s) +++\n", WTERMSIG(status), strsignal(WTERMSIG(status)));
            break ;
        }
        if (WIFSTOPPED(status))
        {
            int sig = WSTOPSIG(status);

            if (sig == (SIGTRAP | 0x80))
            {
                if (fetch_registers(child, &regs) == -1)
                {
                    perror("ptrace(PTRACE_GETREGSET)");
                    return (-1);
                }
                if (!in_syscall)
                {
                    print_syscall_enter(&regs, cfg);
                    in_syscall = 1;
                }
                else
                {
                    print_syscall_exit(&regs);
                    in_syscall = 0;
                }
                if (ptrace(PTRACE_SYSCALL, child, NULL, NULL) == -1)
                {
                    perror("ptrace(PTRACE_SYSCALL)");
                    return (-1);
                }
                continue ;
            }
            else if (sig == SIGTRAP)
            {
                if (ptrace(PTRACE_SYSCALL, child, NULL, NULL) == -1)
                {
                    perror("ptrace(PTRACE_SYSCALL)");
                    return (-1);
                }
                continue ;
            }
            else
            {
                print_signal(sig);
                if (ptrace(PTRACE_SYSCALL, child, NULL, (void *)(long)sig) == -1)
                {
                    perror("ptrace(PTRACE_SYSCALL)");
                    return (-1);
                }
                continue ;
            }
        }
        if (ptrace(PTRACE_SYSCALL, child, NULL, NULL) == -1)
        {
            perror("ptrace(PTRACE_SYSCALL)");
            return (-1);
        }
    }
    return (0);
}

int run_strace(char *const argv[], char *const envp[], const t_trace_config *cfg)
{
    pid_t   child;
    int     status;

    (void)envp;
    child = fork();
    if (child == -1)
    {
        perror("fork");
        return (-1);
    }
    if (child == 0)
    {
        if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) == -1)
        {
            perror("ptrace(PTRACE_TRACEME)");
            _exit(EXIT_FAILURE);
        }
        raise(SIGSTOP);
        execvp(argv[0], argv);
        perror("execvp");
        _exit(EXIT_FAILURE);
    }
    if (waitpid(child, &status, 0) == -1)
    {
        perror("waitpid");
        return (-1);
    }
    if (ptrace(PTRACE_SETOPTIONS, child, NULL,
            (void *)(long)(PTRACE_O_TRACESYSGOOD | PTRACE_O_TRACEEXIT | PTRACE_O_TRACEEXEC | PTRACE_O_EXITKILL)) == -1)
    {
        perror("ptrace(PTRACE_SETOPTIONS)");
        return (-1);
    }
    if (ptrace(PTRACE_SYSCALL, child, NULL, NULL) == -1)
    {
        perror("ptrace(PTRACE_SYSCALL)");
        return (-1);
    }
    return (trace_loop(child, cfg));
}
