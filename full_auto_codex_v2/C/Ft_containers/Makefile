NAME := ft_containers
LIB  := libftcontainers.a

CXX ?= c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++98
CPPFLAGS := -Iinclude
AR := ar
ARFLAGS := rcs

SRC_DIR := src
OBJ_DIR := build

SRCS := $(SRC_DIR)/main.cpp
LIB_SRCS := $(SRC_DIR)/stub.cpp

OBJS := $(SRCS:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)
LIB_OBJS := $(LIB_SRCS:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

all: $(LIB) $(NAME)

$(NAME): $(OBJS) $(LIB)
	$(CXX) $(CXXFLAGS) $(OBJS) $(LIB) -o $@

$(LIB): $(LIB_OBJS)
	$(AR) $(ARFLAGS) $@ $(LIB_OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME) $(LIB)

re: fclean all

run: $(NAME)
	./$(NAME)

.PHONY: all clean fclean re run
