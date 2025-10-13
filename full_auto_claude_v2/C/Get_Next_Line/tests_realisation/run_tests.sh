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

RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"

echo "======================================"
echo "  GET_NEXT_LINE TEST SUITE"
echo "======================================"

# Create test files
echo -e "${YELLOW}[1/4] Creating test files...${RESET}"
mkdir -p test_files

echo -e "Hello World\nThis is line 2\nAnd line 3" > test_files/simple.txt
printf "Line 1\nLine 2 no newline" > test_files/no_final_nl.txt
touch test_files/empty.txt
echo "Single line" > test_files/single.txt
python3 -c "print('A' * 10000)" > test_files/long_line.txt
echo -e "\n\ntext" > test_files/empty_lines.txt

echo -e "${GREEN}✓ Test files created${RESET}"

# Test with BUFFER_SIZE=42
echo -e "${YELLOW}[2/4] Testing with BUFFER_SIZE=42...${RESET}"
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test_gnl
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Compilation failed${RESET}"
    exit 1
fi
./test_gnl
RESULT_42=$?

# Test with BUFFER_SIZE=1
echo -e "\n${YELLOW}[3/4] Testing with BUFFER_SIZE=1...${RESET}"
cc -Wall -Wextra -Werror -D BUFFER_SIZE=1 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test_gnl
./test_gnl
RESULT_1=$?

# Test with BUFFER_SIZE=10000
echo -e "\n${YELLOW}[4/4] Testing with BUFFER_SIZE=10000...${RESET}"
cc -Wall -Wextra -Werror -D BUFFER_SIZE=10000 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test_gnl
./test_gnl
RESULT_10000=$?

# Cleanup
rm -f test_gnl

# Memory leaks check
if command -v valgrind &> /dev/null; then
    echo -e "\n${YELLOW}Checking for memory leaks...${RESET}"
    cc -g -Wall -Wextra -Werror -D BUFFER_SIZE=42 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test_gnl
    valgrind --leak-check=full --error-exitcode=1 ./test_gnl > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ No memory leaks detected${RESET}"
    else
        echo -e "${RED}✗ Memory leaks detected${RESET}"
    fi
    rm -f test_gnl
fi

# Final result
echo -e "\n${YELLOW}=== FINAL RESULTS ===${RESET}"
if [ $RESULT_42 -eq 0 ] && [ $RESULT_1 -eq 0 ] && [ $RESULT_10000 -eq 0 ]; then
    echo -e "${GREEN}All buffer sizes passed! ✓${RESET}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${RESET}"
    exit 1
fi
