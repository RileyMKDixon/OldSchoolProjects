all:  main.c Lab3IO.c
	gcc main.c Lab3IO.c -o main -fopenmp -lm -ggdb -std=gnu99

clean:
	rm ./main

run: all
	./main 4
	./serialtester
