# woody_woodpacker Makefile

NAME = woody_woodpacker
CC = gcc
CFLAGS = -Wall -Wextra -Werror

SRC = woody.c
OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) woody

re: fclean all

.PHONY: all clean fclean re
