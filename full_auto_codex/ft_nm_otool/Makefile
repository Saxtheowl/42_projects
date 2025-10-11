CC := cc
CFLAGS := -Wall -Wextra -Werror -I include
OBJ_DIR := build

COMMON_SRCS := \
	src/file.c \
	src/elf_parser.c \
	src/ft_nm.c \
	src/ft_otool.c

NM_SRCS := src/main_nm.c
OTOOL_SRCS := src/main_otool.c

COMMON_OBJS := $(COMMON_SRCS:src/%.c=$(OBJ_DIR)/%.o)
NM_OBJS := $(NM_SRCS:src/%.c=$(OBJ_DIR)/%.o)
OTOOL_OBJS := $(OTOOL_SRCS:src/%.c=$(OBJ_DIR)/%.o)
DEPS := $(COMMON_OBJS:.o=.d) $(NM_OBJS:.o=.d) $(OTOOL_OBJS:.o=.d)

NM_BIN := ft_nm
OTOOL_BIN := ft_otool

all: $(NM_BIN) $(OTOOL_BIN)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: src/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(NM_BIN): $(COMMON_OBJS) $(NM_OBJS)
	$(CC) $(COMMON_OBJS) $(NM_OBJS) -o $@

$(OTOOL_BIN): $(COMMON_OBJS) $(OTOOL_OBJS)
	$(CC) $(COMMON_OBJS) $(OTOOL_OBJS) -o $@

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NM_BIN) $(OTOOL_BIN)

re: fclean all

.PHONY: all clean fclean re

-include $(DEPS)
