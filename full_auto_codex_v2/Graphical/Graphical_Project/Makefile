NAME := RT
CC := cc
CFLAGS := -Wall -Wextra -Werror -std=c11 -pthread
SRC := src/main.c src/parser.c src/render.c
OBJ := $(SRC:.c=.o)
INCLUDES := -Iinclude

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -lm -o $(NAME)

%.o: %.c include/scene.h include/parser.h
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
