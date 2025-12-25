NAME := animals
CXX := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++98
SRCS := main.cpp Animal.cpp Dog.cpp Cat.cpp
OBJS := $(SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

%.o: %.cpp Animal.hpp Dog.hpp Cat.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
