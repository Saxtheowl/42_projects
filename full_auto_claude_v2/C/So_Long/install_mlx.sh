#!/bin/bash

# Installation script for MiniLibX on Linux

echo "Installing MiniLibX dependencies..."
sudo apt-get update
sudo apt-get install -y gcc make xorg libxext-dev libbsd-dev

echo "Cloning MiniLibX repository..."
cd /tmp
git clone https://github.com/42Paris/minilibx-linux.git
cd minilibx-linux

echo "Compiling MiniLibX..."
make

echo "Installing MiniLibX..."
sudo cp libmlx.a /usr/local/lib/
sudo cp libmlx_Linux.a /usr/local/lib/
sudo cp mlx.h /usr/local/include/
sudo cp mlx_int.h /usr/local/include/

echo "Cleaning up..."
cd ..
rm -rf minilibx-linux

echo "MiniLibX installed successfully!"
echo "You can now compile so_long with 'make'"
