/*
Test the result stored in the "data_output" by a serial version of calculation

-----
Compiling:
    "Lab3IO.c" should be included and "-lm" tag is needed, like
    > gcc serialtester.c Lab3IO.c -o serialtester -lm
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Lab3IO.h"
#include "timer.h"

#define TOL 0.0005

int main(int argc, char *argv[]) {
  int i, j, k, size;
  double **Au;
  double *X;
  double temp, error, Xnorm;
  double startTime, endTime;
  int *index;
  FILE *fp;

  /*Load the datasize and verify it*/
  Lab3LoadInput(&Au, &size);

  /*Calculate the solution by serial code*/
  X = CreateVec(size);
  index = malloc(size * sizeof(int));
  for (i = 0; i < size; ++i)
    index[i] = i;

  GET_TIME(startTime);

  if (size == 1)
    X[0] = Au[0][1] / Au[0][0];
  else {
    /*Gaussian elimination*/
    for (k = 0; k < size - 1; ++k) {
      /*Pivoting*/
      temp = 0;
      for (i = k, j = 0; i < size; ++i)
        if (temp < Au[index[i]][k] * Au[index[i]][k]) {
          temp = Au[index[i]][k] * Au[index[i]][k];
          j = i;
        }
      if (j != k)/*swap*/{
        i = index[j];
        index[j] = index[k];
        index[k] = i;
      }
      /*calculating*/
      for (i = k + 1; i < size; ++i) {
        temp = Au[index[i]][k] / Au[index[k]][k];
        for (j = k; j < size + 1; ++j)
          Au[index[i]][j] -= Au[index[k]][j] * temp;
      }
    }
    /*Jordan elimination*/
    for (k = size - 1; k > 0; --k) {
      for (i = k - 1; i >= 0; --i) {
        temp = Au[index[i]][k] / Au[index[k]][k];
        Au[index[i]][k] -= temp * Au[index[k]][k];
        Au[index[i]][size] -= temp * Au[index[k]][size];
      }
    }
    /*solution*/
    for (k = 0; k < size; ++k)
      X[k] = Au[index[k]][size] / Au[index[k]][k];
  }
  GET_TIME(endTime);
  printf("%f\n", endTime-startTime);

  DestroyVec(X);
  DestroyMat(Au, size);
  free(index);
  return 0;
}
