# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: automated <automated@42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/13 00:00:00 by automated         #+#    #+#              #
#    Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

CC = cc
CFLAGS = -Wall -Wextra -Werror
RM = rm -f

# Mandatory executables
SERVER = server
CLIENT = client

# Bonus executables
SERVER_BONUS = server_bonus
CLIENT_BONUS = client_bonus

# Source files
SERVER_SRC = server.c utils.c
CLIENT_SRC = client.c utils.c
SERVER_BONUS_SRC = server_bonus.c utils.c
CLIENT_BONUS_SRC = client_bonus.c utils.c

# Object files
SERVER_OBJ = $(SERVER_SRC:.c=.o)
CLIENT_OBJ = $(CLIENT_SRC:.c=.o)
SERVER_BONUS_OBJ = $(SERVER_BONUS_SRC:.c=.o)
CLIENT_BONUS_OBJ = $(CLIENT_BONUS_SRC:.c=.o)

# Colors
GREEN = \033[0;32m
NC = \033[0m

# Default target
all: $(SERVER) $(CLIENT)

# Build server
$(SERVER): $(SERVER_OBJ)
	@$(CC) $(CFLAGS) $(SERVER_OBJ) -o $(SERVER)
	@echo "$(GREEN)Server compiled successfully$(NC)"

# Build client
$(CLIENT): $(CLIENT_OBJ)
	@$(CC) $(CFLAGS) $(CLIENT_OBJ) -o $(CLIENT)
	@echo "$(GREEN)Client compiled successfully$(NC)"

# Compile .c to .o
%.o: %.c minitalk.h minitalk_bonus.h
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled: $<"

# Bonus target
bonus: $(SERVER_BONUS) $(CLIENT_BONUS)

# Build server_bonus
$(SERVER_BONUS): $(SERVER_BONUS_OBJ)
	@$(CC) $(CFLAGS) $(SERVER_BONUS_OBJ) -o $(SERVER_BONUS)
	@echo "$(GREEN)Server bonus compiled successfully$(NC)"

# Build client_bonus
$(CLIENT_BONUS): $(CLIENT_BONUS_OBJ)
	@$(CC) $(CFLAGS) $(CLIENT_BONUS_OBJ) -o $(CLIENT_BONUS)
	@echo "$(GREEN)Client bonus compiled successfully$(NC)"

# Clean object files
clean:
	@$(RM) $(SERVER_OBJ) $(CLIENT_OBJ) $(SERVER_BONUS_OBJ) $(CLIENT_BONUS_OBJ)
	@echo "Object files cleaned"

# Clean everything
fclean: clean
	@$(RM) $(SERVER) $(CLIENT) $(SERVER_BONUS) $(CLIENT_BONUS)
	@echo "Executables removed"

# Rebuild everything
re: fclean all

# Phony targets
.PHONY: all clean fclean re bonus
