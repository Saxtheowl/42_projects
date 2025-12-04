NAME := kalman_demo

CXX := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++17
CPPFLAGS := -Iinclude

SRCS := \
	src/main.cpp \
	src/kalman.cpp

TEST_SRCS := tests_realisation/test_kalman.cpp src/kalman.cpp

OBJS := $(SRCS:.cpp=.o)
TEST_OBJS := $(TEST_SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

.PHONY: test
test: kalman_test
	./kalman_test

kalman_test: $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $(TEST_OBJS) -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TEST_OBJS)

fclean: clean
	rm -f $(NAME) kalman_test

re: fclean all

.PHONY: all clean fclean re
