NAME := connect_four
CC := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++98 -Iinclude

SRCS := src/main.cpp src/Game.cpp
OBJS := $(SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CXXFLAGS) $(OBJS) -o $(NAME)

%.o: %.cpp include/Game.hpp
	$(CC) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
