#define _XOPEN_SOURCE 700
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static void usage(const char *prog)
{
    fprintf(stderr, "usage: %s [-p project] [-q question] [-c context] [-m] [-o file]\n", prog);
    exit(EXIT_FAILURE);
}

static char *dup_or_empty(const char *s)
{
    if (!s)
        return strdup("");
    return strdup(s);
}

static void write_markdown(FILE *out, const char *project, const char *question, const char *context, const char *ts)
{
    fprintf(out, "## Help Request\n");
    fprintf(out, "- Timestamp: %s\n", ts);
    fprintf(out, "- Project  : %s\n", *project ? project : "(unspecified)");
    fprintf(out, "- Question : %s\n", *question ? question : "(unspecified)");
    fprintf(out, "- Context  : %s\n\n", *context ? context : "(unspecified)");
    fprintf(out, "### What I tried\n");
    fprintf(out, "1. \n2. \n3. \n\n");
    fprintf(out, "### Expected vs Actual\n");
    fprintf(out, "- Expected: \n- Actual  : \n\n");
    fprintf(out, "### Logs / Error / Repro\n");
    fprintf(out, "- Command: \n- Output : \n");
}

static void write_text(FILE *out, const char *project, const char *question, const char *context, const char *ts)
{
    fprintf(out, "=== Help Request ===\n");
    fprintf(out, "Timestamp : %s\n", ts);
    fprintf(out, "Project   : %s\n", *project ? project : "(unspecified)");
    fprintf(out, "Question  : %s\n", *question ? question : "(unspecified)");
    fprintf(out, "Context   : %s\n", *context ? context : "(unspecified)");
    fprintf(out, "\nWhat I tried:\n");
    fprintf(out, "1. \n");
    fprintf(out, "2. \n");
    fprintf(out, "3. \n");
    fprintf(out, "\nExpected vs actual:\n");
    fprintf(out, "- Expected: \n");
    fprintf(out, "- Actual  : \n");
    fprintf(out, "\nLogs / Error / Repro:\n");
    fprintf(out, "- Command: \n");
    fprintf(out, "- Output : \n");
    fprintf(out, "====================\n");
}

int main(int argc, char **argv)
{
    const char *project = NULL;
    const char *question = NULL;
    const char *context = NULL;
    const char *out_path = NULL;
    int markdown = 0;
    for (int i = 1; i < argc; ++i)
    {
        if (strcmp(argv[i], "-p") == 0 && i + 1 < argc)
            project = argv[++i];
        else if (strcmp(argv[i], "-q") == 0 && i + 1 < argc)
            question = argv[++i];
        else if (strcmp(argv[i], "-c") == 0 && i + 1 < argc)
            context = argv[++i];
        else if (strcmp(argv[i], "-m") == 0)
            markdown = 1;
        else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc)
            out_path = argv[++i];
        else
            usage(argv[0]);
    }
    char *p = dup_or_empty(project);
    char *q = dup_or_empty(question);
    char *c = dup_or_empty(context);
    if (!p || !q || !c)
    {
        fprintf(stderr, "ft_helpme: allocation failed\n");
        free(p); free(q); free(c);
        return EXIT_FAILURE;
    }
    FILE *out = stdout;
    if (out_path)
    {
        out = fopen(out_path, "w");
        if (!out)
        {
            perror("ft_helpme: open output");
            free(p); free(q); free(c);
            return EXIT_FAILURE;
        }
    }
    time_t now = time(NULL);
    char ts[64];
    struct tm *tm = localtime(&now);
    if (tm)
        strftime(ts, sizeof(ts), "%Y-%m-%d %H:%M:%S", tm);
    else
        snprintf(ts, sizeof(ts), "unknown");

    if (markdown)
        write_markdown(out, p, q, c, ts);
    else
        write_text(out, p, q, c, ts);

    if (out_path)
        fclose(out);
    free(p);
    free(q);
    free(c);
    return EXIT_SUCCESS;
}
