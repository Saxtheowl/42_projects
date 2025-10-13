NAME = ft_strace

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc
LDFLAGS =
LDLIBS =

SRCS = \
	src/main.c \
	src/detect.c \
	src/trace.c \
	src/syscall/syscall_lookup.c \
	src/syscall/syscall_table_generated64.c \
	src/syscall/syscall_table_generated32.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
