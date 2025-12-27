NAME = ft_ssl
CC = cc
CFLAGS = -Wall -Wextra -Werror

SRC = src/main.c src/hash.c src/md5.c src/sha256.c
OBJ = $(SRC:.c=.o)

INC = include

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -I$(INC) $(OBJ) -o $@

test: $(NAME)
	./tests_realisation/run_tests.sh

%.o: %.c
	$(CC) $(CFLAGS) -I$(INC) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test
