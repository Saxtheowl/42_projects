NAME := computor_v2
CC := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++98 -Iinclude

SRCS := src/main.cpp src/Interpreter.cpp src/Tokenizer.cpp src/Parser.cpp src/Complex.cpp src/Matrix.cpp src/Value.cpp
OBJS := $(SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CXXFLAGS) $(OBJS) -o $(NAME)

%.o: %.cpp include/Complex.hpp include/Matrix.hpp include/Value.hpp include/Tokenizer.hpp include/Parser.hpp include/Interpreter.hpp
	$(CC) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
