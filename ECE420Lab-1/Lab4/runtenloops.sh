#!/bin/bash
for numNodes in 5300 13000 18789
do
	./datatrim -b $numNodes
	make
	for numProc in {8..1}
	do
		for locality in 0 1
		do
			if [ "$locality" -eq 0 ]; 
			then
				echo "Nodes: $numNodes NP: $numProc LOCAL"
			else
				echo "Nodes: $numNodes NP: $numProc CLUSTER"
			fi
			for i in {1..10}
			do
				if [ "$locality" -eq 0 ]; 
				then
					mpirun -np $numProc ./main
				else
					mpirun -np $numProc -f hosts ./main
				fi
			done
		done
	done
done
		