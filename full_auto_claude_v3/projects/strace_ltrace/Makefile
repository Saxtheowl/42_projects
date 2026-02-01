# strace_ltrace Makefile

NAME = ft_strace
CC = gcc
CFLAGS = -Wall -Wextra -Werror

SRC = strace.c
OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

test: $(NAME)
	./$(NAME) /bin/ls -la 2>&1 | head -20

.PHONY: all clean fclean re test
