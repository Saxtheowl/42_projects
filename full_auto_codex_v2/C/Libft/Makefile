NAME = libft.a

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc
AR = ar rcs

SRCS = \
	src/ft_memory.c \
	src/ft_string.c \
	src/ft_char.c \
	src/ft_additional.c \
	src/ft_split.c \
	src/ft_put.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(AR) $(NAME) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
