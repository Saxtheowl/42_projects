# nm-otool Makefile

CC = gcc
CFLAGS = -Wall -Wextra -Werror

all: ft_nm ft_otool

ft_nm: ft_nm.c
	$(CC) $(CFLAGS) -o ft_nm ft_nm.c

ft_otool: ft_otool.c
	$(CC) $(CFLAGS) -o ft_otool ft_otool.c

clean:
	rm -f *.o

fclean: clean
	rm -f ft_nm ft_otool

re: fclean all

.PHONY: all clean fclean re
