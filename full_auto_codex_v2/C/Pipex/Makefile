NAME = pipex

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc
LDFLAGS =
LDLIBS =

SRCS = \
	src/pipex.c \
	src/utils.c \
	src/parse.c \
	src/errors.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
