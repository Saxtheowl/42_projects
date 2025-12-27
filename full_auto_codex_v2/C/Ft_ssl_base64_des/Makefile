NAME = ft_ssl_base64_des
CC = cc
CFLAGS = -Wall -Wextra -Werror

SRC = src/main.c src/base64.c src/io.c src/des.c src/md5.c
OBJ = $(SRC:.c=.o)
INC = include

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -I$(INC) $(OBJ) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -I$(INC) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

test: $(NAME)
	./tests_realisation/run_tests.sh

.PHONY: all clean fclean re test
