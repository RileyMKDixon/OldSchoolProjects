
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <pthread.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>

#include "lab1_IO.h"
#include <pthread.h>


void handle_error_en(int en, char *msg) {
  errno = en;
  perror(msg);
  exit(EXIT_FAILURE);
}
void handle_error(char *msg) {
  perror(msg);
  exit(EXIT_FAILURE);
}

long get_num_threads(int argc, char* argv[]){
  long numThreads = 0;
  if(argc != 2){
    fprintf(stderr, "usage: lab1 nthreads");
    exit(1);
  }
  numThreads = strtol(argv[1], NULL, 10);
  double nroot = sqrt((double)numThreads);

  if(!numThreads || floor(nroot) != nroot) {
    fprintf(stderr, "must provide a square number");
    exit(1);
  }

  return numThreads;
}

struct thread_info {
    pthread_t thread;
    int **A;
    int **B;
    int **C;
    int n;
    int nthreads;
    int threadid;
};

int calculateElement(int currentX, int currentY, struct thread_info* ti){
  int elementC = 0;
  //Preforms the matrix multiplication operation for one element of the matrix
  for(int counter = 0; counter < ti->n; counter++){
    elementC += ti->A[currentX][counter] * ti->B[counter][currentY];
  }

  return elementC;
}

void *multiply_thread(void *thread_info) {
  struct thread_info* ti = (struct thread_info*)thread_info;
  //BlockX/BlockY correspond to the submatrix the thread operates on.
  int blockX = floor((ti->threadid)/sqrt(ti->nthreads));
  int blockY = ti->threadid%(int)sqrt(ti->nthreads);

  int minX = ti->n/sqrt(ti->nthreads)*blockX;
  int maxX = ti->n/sqrt(ti->nthreads)*(blockX+1)-1;
  int minY = ti->n/sqrt(ti->nthreads)*blockY;
  int maxY = ti->n/sqrt(ti->nthreads)*(blockY+1)-1;

  //currentX/currentY correspond to the element in C being calculated
  for(int currentX = minX; currentX <= maxX; currentX++){
    for(int currentY = minY; currentY <= maxY; currentY++){
      ti->C[currentX][currentY] = calculateElement(currentX, currentY, ti);
    }
  }
  return NULL;
}

int main(int argc, char* argv[]) {
  long num_threads = get_num_threads(argc, argv);
  struct thread_info *tinfo;
  int **A;
  int **B;
  int **C;
  int n, s;
  //time_t startTime;
  //time_t endTime;
  struct timespec startTime;
  struct timespec endTime;
  double timeResult;
  int getTimeResult;

  startTime.tv_sec = 0;
  startTime.tv_nsec = 0;
  endTime.tv_sec = 0;
  endTime.tv_nsec = 0;

  printf("num threads: %li\n", num_threads);
  
  lab1_loadinput(&A, &B, &n);

  C = malloc(n * sizeof(int*));
  for (int i = 0; i < n; i++){
    C[i] = malloc(n * sizeof(int));
  }

  tinfo = calloc(num_threads, sizeof(struct thread_info));
  if (tinfo == NULL){
    handle_error("calloc");
  }

  getTimeResult = clock_gettime(CLOCK_REALTIME, &startTime);
  if(getTimeResult != 0){
    perror("Failed to get start clock time.\n");
  }

  for (int i = 0; i < num_threads; i++) {
    tinfo[i].threadid = i;
    tinfo[i].nthreads = num_threads;
    tinfo[i].A = A;
    tinfo[i].B = B;
    tinfo[i].C = C;
    tinfo[i].n = n;

    s = pthread_create(&(tinfo[i].thread), NULL,
                       &multiply_thread, &tinfo[i]);
    if (s != 0) handle_error_en(s, "pthread_create");
  }

  for (int i = 0; i < num_threads; i++) {
    s = pthread_join(tinfo[i].thread, NULL);
    if (s != 0) handle_error_en(s, "pthread_join");
  }

  getTimeResult = clock_gettime(CLOCK_REALTIME, &endTime);
  if(getTimeResult != 0){
    perror("Failed to get start clock time.\n");
  }

  timeResult = (endTime.tv_sec - startTime.tv_sec) 
                  + (endTime.tv_nsec - startTime.tv_nsec)*pow(10, -9);

  free(tinfo);
  lab1_saveoutput(C, &n, timeResult);
  
  free(C);

  return 0;
}
