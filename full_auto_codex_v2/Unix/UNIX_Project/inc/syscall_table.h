#ifndef SYSCALL_TABLE_H
#define SYSCALL_TABLE_H

typedef struct s_syscall_entry
{
    long        number;
    const char *name;
}   t_syscall_entry;

extern const t_syscall_entry g_syscalls_x86_64[];
extern const t_syscall_entry g_syscalls_i386[];

const char  *syscall_lookup_name(long number, int is_64bit);

#endif
