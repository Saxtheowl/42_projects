NAME := materia
CC := c++
CXXFLAGS := -Wall -Wextra -Werror -std=c++98

SRCS := main.cpp AMateria.cpp Ice.cpp Cure.cpp Character.cpp MateriaSource.cpp
OBJS := $(SRCS:.cpp=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CXXFLAGS) $(OBJS) -o $(NAME)

%.o: %.cpp AMateria.hpp Ice.hpp Cure.hpp Character.hpp ICharacter.hpp MateriaSource.hpp IMateriaSource.hpp
	$(CC) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
