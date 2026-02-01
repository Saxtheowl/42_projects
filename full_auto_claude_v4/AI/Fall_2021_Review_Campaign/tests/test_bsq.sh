#!/bin/bash

# BSQ Test Suite
# Tests the bsq program for correctness

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BSQ="$PROJECT_DIR/bsq"
TEST_MAPS_DIR="$SCRIPT_DIR/maps"
PASSED=0
FAILED=0
TOTAL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create test maps directory
mkdir -p "$TEST_MAPS_DIR"

print_result() {
    local name="$1"
    local status="$2"
    TOTAL=$((TOTAL + 1))
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} $name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $name"
        FAILED=$((FAILED + 1))
    fi
}

# Create test map files
create_test_maps() {
    # Basic 3x3 map with no obstacles
    cat > "$TEST_MAPS_DIR/simple.txt" << 'EOF'
3.ox
...
...
...
EOF

    # Example from subject
    cat > "$TEST_MAPS_DIR/example.txt" << 'EOF'
9.ox
...........................
....o......................
............o..............
...........................
....o......................
...............o...........
...........................
......o..............o.....
..o.......o................
EOF

    # 1x1 map
    cat > "$TEST_MAPS_DIR/one_cell.txt" << 'EOF'
1.ox
.
EOF

    # Map with all obstacles
    cat > "$TEST_MAPS_DIR/all_obstacles.txt" << 'EOF'
3.ox
ooo
ooo
ooo
EOF

    # Map with single empty cell
    cat > "$TEST_MAPS_DIR/single_empty.txt" << 'EOF'
3.ox
ooo
o.o
ooo
EOF

    # Invalid map - different line lengths
    cat > "$TEST_MAPS_DIR/invalid_lengths.txt" << 'EOF'
3.ox
...
....
...
EOF

    # Invalid map - wrong number of lines
    cat > "$TEST_MAPS_DIR/invalid_lines.txt" << 'EOF'
5.ox
...
...
...
EOF

    # Invalid map - duplicate characters
    cat > "$TEST_MAPS_DIR/invalid_chars.txt" << 'EOF'
3..x
...
...
...
EOF

    # Invalid map - missing character in first line
    cat > "$TEST_MAPS_DIR/invalid_header.txt" << 'EOF'
3.o
...
...
...
EOF

    # Invalid map - invalid character in map
    cat > "$TEST_MAPS_DIR/invalid_content.txt" << 'EOF'
3.ox
...
.z.
...
EOF

    # Map with different characters (using _ for empty, * for obstacle, # for full)
    cat > "$TEST_MAPS_DIR/different_chars.txt" << 'EOF'
3_*#
___
___
___
EOF

    # Rectangular map (wider than tall)
    cat > "$TEST_MAPS_DIR/wide.txt" << 'EOF'
2.ox
..........
..........
EOF

    # Rectangular map (taller than wide)
    cat > "$TEST_MAPS_DIR/tall.txt" << 'EOF'
5.ox
..
..
..
..
..
EOF

    # Map with obstacle in corner
    cat > "$TEST_MAPS_DIR/corner_obstacle.txt" << 'EOF'
3.ox
o..
...
...
EOF

    # Large map for performance
    perl -e '
        my $size = 100;
        print "${size}.ox\n";
        for (my $i = 0; $i < $size; $i++) {
            print "." x $size . "\n";
        }
    ' > "$TEST_MAPS_DIR/large_empty.txt"

    # Empty file
    touch "$TEST_MAPS_DIR/empty.txt"

    # Map with only header
    echo "3.ox" > "$TEST_MAPS_DIR/header_only.txt"
}

# Test: Basic compilation
test_compilation() {
    cd "$PROJECT_DIR"
    make re > /dev/null 2>&1
    if [ -f "$BSQ" ]; then
        print_result "Compilation" 0
    else
        print_result "Compilation" 1
        echo -e "${RED}Cannot continue tests without binary${NC}"
        exit 1
    fi
}

# Test: Simple 3x3 map (should fill entire map)
test_simple_map() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/simple.txt")
    local expected="xxx
xxx
xxx"
    if [ "$output" = "$expected" ]; then
        print_result "Simple 3x3 map" 0
    else
        print_result "Simple 3x3 map" 1
        echo "Expected:"
        echo "$expected"
        echo "Got:"
        echo "$output"
    fi
}

# Test: Example from subject
test_example_map() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/example.txt")
    # Check that it contains a 7x7 square
    local square_count=$(echo "$output" | grep -o 'x' | wc -l)
    if [ "$square_count" -eq 49 ]; then
        print_result "Example map (7x7 square)" 0
    else
        print_result "Example map (7x7 square)" 1
        echo "Expected 49 'x' characters, got $square_count"
        echo "Output:"
        echo "$output"
    fi
}

# Test: 1x1 map
test_one_cell() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/one_cell.txt")
    if [ "$output" = "x" ]; then
        print_result "1x1 map" 0
    else
        print_result "1x1 map" 1
    fi
}

# Test: All obstacles (should output unchanged map)
test_all_obstacles() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/all_obstacles.txt")
    local expected="ooo
ooo
ooo"
    if [ "$output" = "$expected" ]; then
        print_result "All obstacles map" 0
    else
        print_result "All obstacles map" 1
    fi
}

# Test: Single empty cell among obstacles
test_single_empty() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/single_empty.txt")
    local expected="ooo
oxo
ooo"
    if [ "$output" = "$expected" ]; then
        print_result "Single empty cell" 0
    else
        print_result "Single empty cell" 1
    fi
}

# Test: Invalid map - different line lengths
test_invalid_lengths() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/invalid_lengths.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Invalid map (line lengths)" 0
    else
        print_result "Invalid map (line lengths)" 1
    fi
}

# Test: Invalid map - wrong number of lines
test_invalid_lines() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/invalid_lines.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Invalid map (line count)" 0
    else
        print_result "Invalid map (line count)" 1
    fi
}

# Test: Invalid map - duplicate characters
test_invalid_chars() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/invalid_chars.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Invalid map (duplicate chars)" 0
    else
        print_result "Invalid map (duplicate chars)" 1
    fi
}

# Test: Invalid map - missing header char
test_invalid_header() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/invalid_header.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Invalid map (incomplete header)" 0
    else
        print_result "Invalid map (incomplete header)" 1
    fi
}

# Test: Invalid map - invalid content character
test_invalid_content() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/invalid_content.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Invalid map (invalid content)" 0
    else
        print_result "Invalid map (invalid content)" 1
    fi
}

# Test: Different characters
test_different_chars() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/different_chars.txt")
    local expected="###
###
###"
    if [ "$output" = "$expected" ]; then
        print_result "Different characters" 0
    else
        print_result "Different characters" 1
    fi
}

# Test: Wide rectangular map
test_wide_map() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/wide.txt")
    # Should have a 2x2 square at top-left
    local first_line=$(echo "$output" | head -1)
    if [[ "$first_line" == "xx"* ]]; then
        print_result "Wide rectangular map" 0
    else
        print_result "Wide rectangular map" 1
    fi
}

# Test: Tall rectangular map
test_tall_map() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/tall.txt")
    # Should have a 2x2 square at top
    local expected="xx
xx
..
..
.."
    if [ "$output" = "$expected" ]; then
        print_result "Tall rectangular map" 0
    else
        print_result "Tall rectangular map" 1
    fi
}

# Test: Corner obstacle
test_corner_obstacle() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/corner_obstacle.txt")
    # Should have a 2x2 square, not at top-left corner
    local square_count=$(echo "$output" | grep -o 'x' | wc -l)
    if [ "$square_count" -eq 4 ]; then
        print_result "Corner obstacle" 0
    else
        print_result "Corner obstacle" 1
    fi
}

# Test: Multiple files
test_multiple_files() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/simple.txt" "$TEST_MAPS_DIR/one_cell.txt")
    # Should contain both outputs separated by newline
    if echo "$output" | grep -q "xxx" && echo "$output" | grep -q "^x$"; then
        print_result "Multiple files" 0
    else
        print_result "Multiple files" 1
    fi
}

# Test: Empty file
test_empty_file() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/empty.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Empty file" 0
    else
        print_result "Empty file" 1
    fi
}

# Test: Header only
test_header_only() {
    local output=$("$BSQ" "$TEST_MAPS_DIR/header_only.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Header only" 0
    else
        print_result "Header only" 1
    fi
}

# Test: Non-existent file
test_nonexistent_file() {
    local output=$("$BSQ" "nonexistent_file_12345.txt" 2>&1)
    if echo "$output" | grep -q "map error"; then
        print_result "Non-existent file" 0
    else
        print_result "Non-existent file" 1
    fi
}

# Test: Reading from stdin
test_stdin() {
    local output=$(echo "3.ox
...
...
..." | "$BSQ")
    local expected="xxx
xxx
xxx"
    if [ "$output" = "$expected" ]; then
        print_result "Reading from stdin" 0
    else
        print_result "Reading from stdin" 1
    fi
}

# Test: Large map performance
test_large_map() {
    local start=$(date +%s%N)
    local output=$("$BSQ" "$TEST_MAPS_DIR/large_empty.txt")
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))  # milliseconds

    # Should complete in under 5 seconds
    if [ "$duration" -lt 5000 ]; then
        print_result "Large map performance (<5s)" 0
    else
        print_result "Large map performance (<5s)" 1
        echo "Took ${duration}ms"
    fi
}

# Test: Makefile clean
test_makefile_clean() {
    cd "$PROJECT_DIR"
    make clean > /dev/null 2>&1
    if ls *.o 2>/dev/null | grep -q .; then
        print_result "Makefile clean" 1
    else
        print_result "Makefile clean" 0
    fi
    make > /dev/null 2>&1
}

# Test: Makefile fclean
test_makefile_fclean() {
    cd "$PROJECT_DIR"
    make fclean > /dev/null 2>&1
    if [ -f "$BSQ" ]; then
        print_result "Makefile fclean" 1
    else
        print_result "Makefile fclean" 0
    fi
    make > /dev/null 2>&1
}

# Test: Makefile no relink
test_makefile_no_relink() {
    cd "$PROJECT_DIR"
    make > /dev/null 2>&1
    local first_output=$(make 2>&1)
    if echo "$first_output" | grep -q "Nothing to be done\|is up to date"; then
        print_result "Makefile no relink" 0
    else
        print_result "Makefile no relink" 1
    fi
}

# Main test runner
main() {
    echo -e "${YELLOW}=== BSQ Test Suite ===${NC}"
    echo ""

    create_test_maps

    echo -e "${YELLOW}--- Compilation Tests ---${NC}"
    test_compilation

    echo ""
    echo -e "${YELLOW}--- Makefile Tests ---${NC}"
    test_makefile_clean
    test_makefile_fclean
    test_makefile_no_relink

    echo ""
    echo -e "${YELLOW}--- Basic Functionality Tests ---${NC}"
    test_simple_map
    test_example_map
    test_one_cell
    test_all_obstacles
    test_single_empty
    test_different_chars

    echo ""
    echo -e "${YELLOW}--- Shape Tests ---${NC}"
    test_wide_map
    test_tall_map
    test_corner_obstacle

    echo ""
    echo -e "${YELLOW}--- Input Tests ---${NC}"
    test_multiple_files
    test_stdin

    echo ""
    echo -e "${YELLOW}--- Error Handling Tests ---${NC}"
    test_invalid_lengths
    test_invalid_lines
    test_invalid_chars
    test_invalid_header
    test_invalid_content
    test_empty_file
    test_header_only
    test_nonexistent_file

    echo ""
    echo -e "${YELLOW}--- Performance Tests ---${NC}"
    test_large_map

    echo ""
    echo -e "${YELLOW}=== Summary ===${NC}"
    echo -e "Total: $TOTAL | ${GREEN}Passed: $PASSED${NC} | ${RED}Failed: $FAILED${NC}"

    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

main "$@"
