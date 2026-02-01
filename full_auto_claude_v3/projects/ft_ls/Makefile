NAME = ft_ls
CC = cc
CFLAGS = -Wall -Wextra -Werror
SRCDIR = src
SRCS = $(SRCDIR)/main.c $(SRCDIR)/utils.c $(SRCDIR)/files.c $(SRCDIR)/sort.c $(SRCDIR)/display.c
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
