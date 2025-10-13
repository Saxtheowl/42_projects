#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    run_tests.sh                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: auto-generated <noreply@anthropic.com>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/13 00:00:00 by auto-gen          #+#    #+#              #
#    Updated: 2025/10/13 00:00:00 by auto-gen         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

echo "======================================"
echo "  FT_PRINTF TEST SUITE"
echo "======================================"

# Colors
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"

# Compile library
echo -e "${YELLOW}[1/3] Compiling library...${RESET}"
(cd .. && make fclean > /dev/null 2>&1)
(cd .. && make > /dev/null 2>&1)
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Library compilation failed${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ Library compiled successfully${RESET}"

# Compile test program
echo -e "${YELLOW}[2/3] Compiling test program...${RESET}"
cc -Wall -Wextra -Werror test_main.c -L.. -lftprintf -o test_printf 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Test compilation failed${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ Test program compiled successfully${RESET}"

# Run tests
echo -e "${YELLOW}[3/3] Running tests...${RESET}"
./test_printf
TEST_RESULT=$?

# Cleanup
rm -f test_printf

# Check memory leaks (optional)
if command -v valgrind &> /dev/null; then
    echo -e "\n${YELLOW}Checking for memory leaks...${RESET}"
    cc -g -Wall -Wextra -Werror test_main.c -L.. -lftprintf -o test_printf 2>&1 > /dev/null
    valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all \
             --error-exitcode=1 ./test_printf > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ No memory leaks detected${RESET}"
    else
        echo -e "${RED}✗ Memory leaks detected${RESET}"
        echo -e "${YELLOW}Run: valgrind --leak-check=full ./test_printf${RESET}"
    fi
    rm -f test_printf
fi

exit $TEST_RESULT
