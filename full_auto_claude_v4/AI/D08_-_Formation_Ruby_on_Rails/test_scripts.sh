#!/bin/bash
# Test script to validate D08_-_Formation_Ruby_on_Rails exercises
# Tests shell script syntax and required file existence

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    FAIL=$((FAIL + 1))
}

echo "=== Testing D08_-_Formation_Ruby_on_Rails ==="
echo ""

# Test Ex00 files exist
echo "--- Exercise 00 Tests ---"

if [ -f "$SCRIPT_DIR/ex00/create_server.sh" ]; then
    pass "ex00/create_server.sh exists"
else
    fail "ex00/create_server.sh missing"
fi

if [ -f "$SCRIPT_DIR/ex00/Vagrantfile" ]; then
    pass "ex00/Vagrantfile exists"
else
    fail "ex00/Vagrantfile missing"
fi

# Test Ex00 script syntax
if bash -n "$SCRIPT_DIR/ex00/create_server.sh" 2>/dev/null; then
    pass "ex00/create_server.sh has valid bash syntax"
else
    fail "ex00/create_server.sh has syntax errors"
fi

# Test Ex00 script content requirements
if grep -q "rvm install" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh contains RVM installation"
else
    fail "ex00/create_server.sh missing RVM installation"
fi

if grep -q "rails new foubarre" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh creates foubarre app"
else
    fail "ex00/create_server.sh missing foubarre app creation"
fi

if grep -q "postgresql" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh configures PostgreSQL"
else
    fail "ex00/create_server.sh missing PostgreSQL configuration"
fi

if grep -q "RAILS_ENV=production" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh sets production environment"
else
    fail "ex00/create_server.sh missing production environment"
fi

if grep -q "SECRET_KEY_BASE" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh configures SECRET_KEY_BASE"
else
    fail "ex00/create_server.sh missing SECRET_KEY_BASE"
fi

if grep -q "0.0.0.0" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh configures /etc/hosts"
else
    fail "ex00/create_server.sh missing /etc/hosts configuration"
fi

if grep -q "rails server" "$SCRIPT_DIR/ex00/create_server.sh" || grep -q "puma" "$SCRIPT_DIR/ex00/create_server.sh"; then
    pass "ex00/create_server.sh starts the server"
else
    fail "ex00/create_server.sh missing server start"
fi

echo ""
echo "--- Exercise 01 Tests ---"

# Test Ex01 files exist
if [ -f "$SCRIPT_DIR/ex01/create_server_2.sh" ]; then
    pass "ex01/create_server_2.sh exists"
else
    fail "ex01/create_server_2.sh missing"
fi

if [ -f "$SCRIPT_DIR/ex01/create_app.sh" ]; then
    pass "ex01/create_app.sh exists"
else
    fail "ex01/create_app.sh missing"
fi

if [ -f "$SCRIPT_DIR/ex01/Vagrantfile" ]; then
    pass "ex01/Vagrantfile exists"
else
    fail "ex01/Vagrantfile missing"
fi

# Test Ex01 script syntax
if bash -n "$SCRIPT_DIR/ex01/create_server_2.sh" 2>/dev/null; then
    pass "ex01/create_server_2.sh has valid bash syntax"
else
    fail "ex01/create_server_2.sh has syntax errors"
fi

if bash -n "$SCRIPT_DIR/ex01/create_app.sh" 2>/dev/null; then
    pass "ex01/create_app.sh has valid bash syntax"
else
    fail "ex01/create_app.sh has syntax errors"
fi

# Test Ex01 create_server_2.sh content requirements
if grep -q "deploy" "$SCRIPT_DIR/ex01/create_server_2.sh"; then
    pass "ex01/create_server_2.sh creates deploy user"
else
    fail "ex01/create_server_2.sh missing deploy user creation"
fi

if grep -q "nginx" "$SCRIPT_DIR/ex01/create_server_2.sh"; then
    pass "ex01/create_server_2.sh installs nginx"
else
    fail "ex01/create_server_2.sh missing nginx installation"
fi

if grep -q "rvm" "$SCRIPT_DIR/ex01/create_server_2.sh"; then
    pass "ex01/create_server_2.sh installs RVM"
else
    fail "ex01/create_server_2.sh missing RVM installation"
fi

if grep -q "puma" "$SCRIPT_DIR/ex01/create_server_2.sh"; then
    pass "ex01/create_server_2.sh configures Puma"
else
    fail "ex01/create_server_2.sh missing Puma configuration"
fi

# Test Ex01 create_app.sh content requirements
if grep -q "capistrano" "$SCRIPT_DIR/ex01/create_app.sh"; then
    pass "ex01/create_app.sh includes Capistrano"
else
    fail "ex01/create_app.sh missing Capistrano"
fi

if grep -q "nginx" "$SCRIPT_DIR/ex01/create_app.sh"; then
    pass "ex01/create_app.sh includes nginx config"
else
    fail "ex01/create_app.sh missing nginx config"
fi

if grep -q "bitbucket" "$SCRIPT_DIR/ex01/create_app.sh"; then
    pass "ex01/create_app.sh references Bitbucket"
else
    fail "ex01/create_app.sh missing Bitbucket reference"
fi

if grep -q "post_deploy_symlink" "$SCRIPT_DIR/ex01/create_app.sh"; then
    pass "ex01/create_app.sh creates post_deploy_symlink script"
else
    fail "ex01/create_app.sh missing post_deploy_symlink script"
fi

# Test Vagrantfiles
if grep -q "ubuntu" "$SCRIPT_DIR/ex00/Vagrantfile"; then
    pass "ex00/Vagrantfile uses Ubuntu box"
else
    fail "ex00/Vagrantfile missing Ubuntu box"
fi

if grep -q "ubuntu" "$SCRIPT_DIR/ex01/Vagrantfile"; then
    pass "ex01/Vagrantfile uses Ubuntu box"
else
    fail "ex01/Vagrantfile missing Ubuntu box"
fi

echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
