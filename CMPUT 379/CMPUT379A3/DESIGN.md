First we read & write in blocks to reduce the amount of time we spend I/O bound.

Secondly we read in the data line by line using the newline character as a
deliminator. The program is designed to just move a pointer along the buffer to
continue reading in data to reduce the amount of overwriting needed to be done
with the buffer. Input validation is done by reading in the first 2 characters
as lackey will assign them accordingly to the memory access type.

"I " - Instruction fetch.
" M" - Multiple memory accesses.
" S" - Store an amount of memory.
" L" - Load an amount of memory.

Should the -i argument be passed, all lines that start with "I " are ignored.
This is done through isValidLine().

Pipe plumbing is setup as a bash line redirecting the output from STDERR to
STDIN and rewriting the program to read from STDIN instead of the read end of a
UNIX pipe.

This bash script looks like:
"valgrind --tool=lackey --trace-mem=yes <PROGRAM> |& ./valws379 <PG_SZIE> <WINDOW_SIZE>"

GNUPLOT was used to generate the plot from the output of valws379.
