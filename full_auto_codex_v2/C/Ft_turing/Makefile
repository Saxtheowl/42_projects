NAME := ft_turing
CXX := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++17
CPPFLAGS := -Iinclude

SRCS := src/main.cpp src/parser.cpp src/simulator.cpp
OBJS := $(SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

.PHONY: test
test: $(NAME)
	./examples/run_tests.sh

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
