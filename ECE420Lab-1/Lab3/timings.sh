for size in 100 500 1000; do
   echo "gen $size"
   ./datagen -s $size -o "data_input_$size"
done

for size in 100 500 1000; do
   ln -s -f "data_input_$size" data_input
   for threads in 1 2 4; do
      TIMES=""
      for i in $(seq 1 10); do
         #TIME=$(sudo chrt -r 1 taskset 0x3 ./main $threads)
         TIME=$(./main $threads)
         TIMES="$TIMES\t$TIME"
      done
      printf "$size\t$threads\t$TIMES\n"
   done
done