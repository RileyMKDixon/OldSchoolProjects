#!/bin/bash

NAME=$1

valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 16 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 32 64
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 64 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 128 64
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 256 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 512 64
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 2048 64
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 4096 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 8192 64
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 16384 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 32768 64
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 65536 64

valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 16
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 32
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 128
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 256
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 512
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 1024
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 2048
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 4096
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 8192
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 16384
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 32768
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 1024 65536

valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 16
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 32
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 64
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 128
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 256
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 512
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 1024
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 2048
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 4096
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 8192
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 16384
#valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 32768
valgrind --tool=lackey --trace-mem=yes ./$NAME |& ./valws379 -i 1024 65536
