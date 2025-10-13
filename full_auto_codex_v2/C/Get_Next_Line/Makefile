NAME = get_next_line.a

CC = cc
CFLAGS = -Wall -Wextra -Werror -Isrc
AR = ar rcs

SRCS = \
	src/get_next_line.c \
	src/get_next_line_utils.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(AR) $(NAME) $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -D BUFFER_SIZE=42 -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

bonus: all

.PHONY: all clean fclean re bonus
