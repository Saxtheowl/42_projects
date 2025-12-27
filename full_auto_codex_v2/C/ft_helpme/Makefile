NAME := ft_helpme
CC := cc
CFLAGS := -Wall -Wextra -Werror
SRC := src/main.c
OBJ := $(SRC:.c=.o)
TEST := tests_realisation/run_tests.sh

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

test: $(NAME)
	$(TEST)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test
