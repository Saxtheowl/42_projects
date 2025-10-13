#include "syscall_table.h"

#include <stddef.h>

const char *syscall_lookup_name(long number, int is_64bit)
{
    const t_syscall_entry *table;

    table = is_64bit ? g_syscalls_x86_64 : g_syscalls_i386;
    for (; table->number != -1; ++table)
    {
        if (table->number == number)
            return table->name;
    }
    return NULL;
}
