NAME := ft_newton
CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Werror
SRC := src/main.cpp src/vector3.cpp src/rigid_body.cpp src/scene.cpp
OBJ := $(SRC:.cpp=.o)
TEST := tests_realisation/run_tests.sh

all: $(NAME)

$(NAME): $(OBJ)
	$(CXX) $(CXXFLAGS) $(OBJ) -o $(NAME)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

run: $(NAME)
	./$(NAME)

test: $(NAME)
	$(TEST)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test run
