NAME = ft_ping
CC = cc
CFLAGS = -Wall -Wextra -Werror
LDFLAGS = -lm
SRCDIR = src
SRCS = $(SRCDIR)/main.c $(SRCDIR)/ping.c $(SRCDIR)/utils.c
OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
