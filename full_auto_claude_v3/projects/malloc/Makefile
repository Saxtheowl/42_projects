# ft_malloc Makefile

NAME = libft_malloc.so
TEST = malloc_test
CC = gcc
CFLAGS = -Wall -Wextra -Werror -fPIC

SRC = malloc.c
OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) -shared -o $(NAME) $(OBJ) -lpthread

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

test: $(OBJ)
	$(CC) $(CFLAGS) -DTEST_MALLOC -o $(TEST) $(SRC) -lpthread

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) $(TEST)

re: fclean all

.PHONY: all clean fclean re test
