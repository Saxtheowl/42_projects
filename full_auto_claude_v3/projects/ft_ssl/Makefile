NAME = ft_ssl
CC = cc
CFLAGS = -Wall -Wextra -Werror
SRCDIR = src
SRCS = $(SRCDIR)/main.c $(SRCDIR)/utils.c $(SRCDIR)/md5.c $(SRCDIR)/sha256.c \
       $(SRCDIR)/process.c $(SRCDIR)/base64.c $(SRCDIR)/des.c $(SRCDIR)/cipher.c
OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
