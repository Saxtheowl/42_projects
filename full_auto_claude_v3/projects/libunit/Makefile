# libunit Makefile

NAME = libunit.a
DEMO = demo_tests
CC = gcc
CFLAGS = -Wall -Wextra -Werror

SRC = libunit.c
OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	ar rcs $(NAME) $(OBJ)

%.o: %.c libunit.h
	$(CC) $(CFLAGS) -c $< -o $@

demo: $(OBJ)
	$(CC) $(CFLAGS) -DDEMO_TESTS -o $(DEMO) $(SRC)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) $(DEMO)

re: fclean all

.PHONY: all clean fclean re demo
