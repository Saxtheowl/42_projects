#!/usr/bin/env bash
set -euo pipefail

CC=${CC:-gcc}
CFLAGS=${CFLAGS:--Wall -Wextra -Werror -Iinclude}
$CC $CFLAGS src/main.c src/config.c src/args.c src/log.c -o ft_services

mkdir -p tests/env/log
mkdir -p tests/env
touch tests/env/ft_services.conf tests/env/ft_services tests/env/log/ft_services.log
FT_SERVICES_CONF=$(pwd)/tests/env/ft_services.conf \
FT_SERVICES_DIR=$(pwd)/tests/env/ft_services \
FT_SERVICES_LOG=$(pwd)/tests/env/log/ft_services.log \
./scripts/check_env.sh
