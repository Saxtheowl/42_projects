#include "log.h"
#include <time.h>
#include <unistd.h>
#include <string.h>

int log_event(int fd, const char *event) {
    if (fd < 0 || !event)
        return -1;
    char buf[256];
    time_t now = time(NULL);
    struct tm tm;
    localtime_r(&now, &tm);
    int len = strftime(buf, sizeof buf, "%Y-%m-%d %H:%M:%S", &tm);
    if (len <= 0)
        return -1;
    len += snprintf(buf + len, sizeof buf - len, " %s\n", event);
    return write(fd, buf, len);
}
