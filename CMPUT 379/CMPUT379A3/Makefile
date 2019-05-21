STDFLAGS = -std=c99 -D_GNU_SOURCE
NAME = valws379
TESTLOOP = testLoopProgram
MERGE = mergesort
QUICK = quicksort
HEAP = heapsort

all: $(NAME).c testLoopProgram heapsort quicksort mergesort
	gcc $(STDFLAGS) $(NAME).c -o $(NAME).bin
	#ln -s ./valws379.bin ./valws379

testLoopProgram: $(TESTLOOP).c
	gcc $(STDFLAGS) $(TESTLOOP).c -o $(TESTLOOP)

heapsort: $(HEAP).c
	gcc $(STDFLAGS) $(HEAP).c -o $(HEAP)

quicksort: $(QUICK).c
	gcc $(STDFLAGS) $(QUICK).c -o $(QUICK)

mergesort: $(MERGE).c
	gcc $(STDFLAGS) $(MERGE).c -o $(MERGE)

clean:
	rm ./valws379.bin
	rm ./valws379
	rm ./testLoopProgram
	rm ./heapsort
	rm ./quicksort
	rm ./mergesort

cleandata:
	rm ./*.dat
