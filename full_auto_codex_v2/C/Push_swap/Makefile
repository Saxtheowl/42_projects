NAME = push_swap

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc

SRCS = \
	src/main.c \
	src/utils.c \
	src/stack.c \
	src/parsing.c \
	src/ops_swap.c \
	src/ops_push.c \
	src/ops_rotate.c \
	src/sort.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
