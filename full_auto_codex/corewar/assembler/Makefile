NAME := asm
CC := c
CFLAGS := -Wall -Wextra -Werror -std=c99 -Iinclude

SRCS := src/main.c src/tokenizer.c src/token.c
OBJS := $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

%.o: %.c include/token.h include/tokenizer.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
