NAME := expert
CC := cc
CFLAGS := -Wall -Wextra -Werror -std=c11
SRC := src/main.c src/parser.c src/ast.c
OBJ := $(SRC:.c=.o)
INCLUDES := -Iinclude

all: $(NAME)

test: $(NAME)
	cd tests && ./run_tests.sh

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
