#!/bin/bash

# Compiling the LuaJIT lib with symbols & debug info
wget https://github.com/LuaJIT/LuaJIT/archive/refs/tags/v2.1.0-beta3.tar.gz
tar -xvf v2.1.0-beta3.tar.gz
cd LuaJIT-2.1.0-beta3/
make -j$(nproc) CCDEBUG=-g3
cd ../

# Compile the dev env & link it with our `libluajit.so` lib.
LD_LIBRARY_PATH=$(pwd)/LuaJIT-2.1.0-beta3/src/:$LD_LIBRARY_PATH \
gcc luajit-expdev.c \
    -g3 \
    -I./LuaJIT-2.1.0-beta3/src/ \
    -L$(pwd)/LuaJIT-2.1.0-beta3/src/ \
    -lluajit \
    -o luajit-expdev

cp ./LuaJIT-2.1.0-beta3/src/libluajit.so libluajit-5.1.so.2
