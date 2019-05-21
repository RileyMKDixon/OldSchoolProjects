#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <omp.h>

#include "timer.h"
#include "Lab3IO.h"
#include <stdbool.h>


int main(int argc, char* argv[]) {
    if(argc != 2){
        printf("Invalid number of arguments.\n");
        exit(1);
    }
    long int numOfThreads = strtol(argv[1], NULL, 10);
    if(numOfThreads < 1){
        printf("Number of threads must be a positive integer.\n");
        exit(2);
    }

    double** matrixA;
    int sizeOfMatrix;
    double* productVector;
    int productSize;
    double startTime;
    double endTime;

    Lab3LoadInput(&matrixA, &sizeOfMatrix);
    productVector = CreateVec(sizeOfMatrix);

    int* index = malloc(sizeOfMatrix * sizeof(int));
    int i, j, k;
    double temp;

    /*
    Credit goes to the ECE 420 TA for the provided serial implementation of the Guassian-Jordan
    Elimination algorithm. Our work improves on it by parallelizing the algorithm with OpenMP.
    */

    //This just sets up an array from 1:sizeOfMatrix, don't think this needs omp
    for (int i = 0; i < sizeOfMatrix; ++i)
        index[i] = i;

    GET_TIME(startTime);

    if (sizeOfMatrix == 1)
        productVector[0] = matrixA[0][1] / matrixA[0][0];
    else {
        /*Gaussian elimination*/

        for (k = 0; k < sizeOfMatrix - 1; ++k) {
            /*Pivoting*/
            temp = 0;
            j = 0;

            #pragma omp parallel for num_threads(numOfThreads) schedule(auto)
            for (i = k; i < sizeOfMatrix; ++i){
                if (temp < matrixA[index[i]][k] * matrixA[index[i]][k]) {
                    temp = matrixA[index[i]][k] * matrixA[index[i]][k];
                    j = i;
                }
            }

            if (j != k)/*swap*/{
                i = index[j];
                index[j] = index[k];
                index[k] = i;
            }

            /*calculating*/
            //collapsable? No due to temp assignment loop is not perfectly nested

            #pragma omp parallel for num_threads(numOfThreads) private(j, temp) schedule(auto)
            for (i = k + 1; i < sizeOfMatrix; ++i) {
                temp = matrixA[index[i]][k] / matrixA[index[k]][k];
                for (j = k; j < sizeOfMatrix + 1; ++j){
                    matrixA[index[i]][j] -= matrixA[index[k]][j] * temp;
                }
            }
        }
        /*Jordan elimination*/
        //rectangular execution space. could be collapsed

        for (k = sizeOfMatrix - 1; k > 0; --k) {
            #pragma omp privatefirst(k) parallel for num_threads(numOfThreads) private(i, temp) schedule(auto)
            for (i = k - 1; i >= 0; --i) {
                temp = matrixA[index[i]][k] / matrixA[index[k]][k];
                matrixA[index[i]][k] -= temp * matrixA[index[k]][k];
                matrixA[index[i]][sizeOfMatrix] -= temp * matrixA[index[k]][sizeOfMatrix];
            }
        }

        /*solution*/
        #pragma omp parallel for num_threads(numOfThreads) schedule(auto)
        for (int k = 0; k < sizeOfMatrix; ++k){
            productVector[k] = matrixA[index[k]][sizeOfMatrix] / matrixA[index[k]][k];
        }
    }

    GET_TIME(endTime);
    printf("%f\n", endTime-startTime);

    Lab3SaveOutput(productVector, sizeOfMatrix, endTime-startTime);

    free(index);
    DestroyMat(matrixA, sizeOfMatrix);
    DestroyVec(productVector);
    return 0;
}