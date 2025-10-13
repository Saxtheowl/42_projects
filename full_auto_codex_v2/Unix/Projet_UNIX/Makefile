NAME = Durex

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc
LDFLAGS =
LDLIBS =

SRCS = \
	src/main.c \
	src/config.c \
	src/run.c \
	src/sha256.c

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
