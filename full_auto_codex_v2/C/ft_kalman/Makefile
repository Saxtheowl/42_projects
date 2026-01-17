NAME := kalman_demo

CXX := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++17
CPPFLAGS := -Iinclude

SRCS := \
	src/main.cpp \
	src/kalman.cpp \
	src/udp.cpp

CLIENT_SRCS := src/client.cpp src/udp.cpp

TEST_SRCS := tests_realisation/test_kalman.cpp src/kalman.cpp

OBJS := $(SRCS:.cpp=.o)
CLIENT_OBJS := $(CLIENT_SRCS:.cpp=.o)
TEST_OBJS := $(TEST_SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

.PHONY: client
client: kalman_client

kalman_client: $(CLIENT_OBJS)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(CLIENT_OBJS) -o $@

.PHONY: test
test: kalman_test
	./kalman_test

.PHONY: test-udp
test-udp:
	./tests_realisation/run_udp.sh

.PHONY: test-all
test-all: test test-udp

kalman_test: $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $(TEST_OBJS) -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TEST_OBJS) $(CLIENT_OBJS)

fclean: clean
	rm -f $(NAME) kalman_test kalman_client

re: fclean all

.PHONY: all clean fclean re
