#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

typedef struct s_entry
{
    char            *name;
    time_t          mtime;
#ifdef __APPLE__
    long            mtime_nsec;
#else
    long            mtime_nsec;
#endif
}   t_entry;

static int cmp_entries(const void *a, const void *b)
{
    const t_entry *ea = (const t_entry *)a;
    const t_entry *eb = (const t_entry *)b;
    if (ea->mtime != eb->mtime)
        return (ea->mtime < eb->mtime) ? -1 : 1;
    if (ea->mtime_nsec != eb->mtime_nsec)
        return (ea->mtime_nsec < eb->mtime_nsec) ? -1 : 1;
    return strcmp(ea->name, eb->name);
}

static void free_entries(t_entry *entries, size_t count)
{
    for (size_t i = 0; i < count; ++i)
        free(entries[i].name);
    free(entries);
}

static int collect_entries(t_entry **out_entries, size_t *out_count)
{
    DIR *dir = opendir(".");
    if (!dir)
    {
        perror("ft_mini_ls");
        return -1;
    }
    struct dirent *ent;
    size_t cap = 32;
    size_t count = 0;
    t_entry *entries = malloc(cap * sizeof(t_entry));
    if (!entries)
    {
        closedir(dir);
        perror("ft_mini_ls");
        return -1;
    }
    while ((ent = readdir(dir)) != NULL)
    {
        if (ent->d_name[0] == '.')
            continue;
        struct stat st;
        if (stat(ent->d_name, &st) != 0)
        {
            perror("ft_mini_ls");
            continue;
        }
        if (count == cap)
        {
            size_t new_cap = cap * 2;
            t_entry *tmp = realloc(entries, new_cap * sizeof(t_entry));
            if (!tmp)
            {
                perror("ft_mini_ls");
                free_entries(entries, count);
                closedir(dir);
                return -1;
            }
            entries = tmp;
            cap = new_cap;
        }
        entries[count].name = strdup(ent->d_name);
        if (!entries[count].name)
        {
            perror("ft_mini_ls");
            free_entries(entries, count);
            closedir(dir);
            return -1;
        }
        entries[count].mtime = st.st_mtime;
#ifdef __APPLE__
        entries[count].mtime_nsec = st.st_mtimespec.tv_nsec;
#else
        entries[count].mtime_nsec = st.st_mtim.tv_nsec;
#endif
        count++;
    }
    closedir(dir);
    *out_entries = entries;
    *out_count = count;
    return 0;
}

int main(int argc, char **argv)
{
    if (argc != 1)
    {
        fprintf(stderr, "ft_mini_ls: this program takes no arguments\n");
        return EXIT_FAILURE;
    }
    (void)argv;
    t_entry *entries = NULL;
    size_t count = 0;
    if (collect_entries(&entries, &count) != 0)
        return EXIT_FAILURE;
    qsort(entries, count, sizeof(t_entry), cmp_entries);
    for (size_t i = 0; i < count; ++i)
        printf("%s\n", entries[i].name);
    free_entries(entries, count);
    return EXIT_SUCCESS;
}
