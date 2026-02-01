# death Makefile

NAME = death
CC = gcc
CFLAGS = -Wall -Wextra -Werror -g -rdynamic

SRC = death.c
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
	@echo "=== Test 1: Segfault ==="
	./$(NAME) 1 || true
	@echo ""
	@echo "=== Test 2: Div Zero ==="
	./$(NAME) 2 || true
	@echo ""
	@echo "=== Test 3: Safe ==="
	./$(NAME) 3

.PHONY: all clean fclean re test
