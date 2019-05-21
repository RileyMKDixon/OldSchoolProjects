#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

#include "timer.h"
#include "Lab4_IO.h"
#include "mpi.h"

#include <stdbool.h>
#include <stdint.h>

#define EPSILON 0.00001
#define DAMPING_FACTOR 0.85

#define THRESHOLD 0.0001

void syncSharedArrays(double *contribution, double *r, int *recvCounts, int *startPartitions);
double *iterate(struct node *nodehead, int myNodeCount, int totalNodeCount, int myRank, int *recvCounts, int *startPartitions, int *endPartitions);
int getNodeCount();
int getEdgeCount(struct node* headNode, int numOfNodes);
void splitVectorIntoPartitions(int numOfProcesses, int numOfEdges, int numOfNodes, 
                                 struct node* headNode, int** startPartition, 
                                 int** endPartition);



int main(int argc, char* argv[]){

    struct node* headNode;
    int numOfNodes;
    int numOfEdges;
    int numOfProcesses;
    int myRankInMPI;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numOfProcesses);
    MPI_Comm_rank(MPI_COMM_WORLD, &myRankInMPI);

    int* startPartitions = calloc(numOfProcesses, sizeof(int));
    int* endPartitions = calloc(numOfProcesses, sizeof(int));

    //Guarantees a continuous data block, and that the block is over, but as close to 1/4 of the total number of edges
    //This does mean our 4th block will be smaller than the rest, but it does ensure all nodes are accounted for.
    if(myRankInMPI == 0){
        numOfNodes = getNodeCount();
        node_init(&headNode, 0, numOfNodes);
        numOfEdges = getEdgeCount(headNode, numOfNodes); //This is also the total weighted sum of all the edges
        splitVectorIntoPartitions(numOfProcesses, numOfEdges, numOfNodes, 
                                    headNode, &startPartitions, &endPartitions);
    }
    MPI_Barrier(MPI_COMM_WORLD); //This may not be necessary as the other
                                 //Processes will block until it receives the
                                 //broadcast from main process.

    MPI_Bcast(startPartitions, numOfProcesses, MPI_INT, 0, MPI_COMM_WORLD); //0 hardcoded as it is the one that has done work
    MPI_Bcast(endPartitions, numOfProcesses, MPI_INT, 0, MPI_COMM_WORLD); //0 hardcoded as it is the one that has done work
    MPI_Bcast(&numOfNodes, 1, MPI_INT, 0, MPI_COMM_WORLD); //0 hardcoded as it is the one that has done work

    if(myRankInMPI == 0) {
        node_destroy(headNode, numOfNodes);
        //printf("Num Processes: %d\n", numOfProcesses);
    }

    node_init(&headNode, startPartitions[myRankInMPI], endPartitions[myRankInMPI]);
    int* recvCounts = malloc(sizeof(int) * numOfNodes);
    for(int i = 0; i < numOfProcesses; ++i) {
        recvCounts[i] = endPartitions[i] - startPartitions[i];
    }

    //fprintf(stderr, "Done loading data\n");
    MPI_Barrier(MPI_COMM_WORLD);

    //printf("Process %d has %d nodes. Total nodes: %d\n", myRankInMPI, endPartitions[myRankInMPI] - startPartitions[myRankInMPI], numOfNodes);
    double start, end;
    GET_TIME(start);

    double *r = iterate(headNode,
            endPartitions[myRankInMPI] - startPartitions[myRankInMPI],
            numOfNodes,
            myRankInMPI,
            recvCounts,
            startPartitions,
            endPartitions);

    if(myRankInMPI == 0) {
        GET_TIME(end);

        double t = end-start;
        printf("%f\n", t);
        Lab4_saveoutput(r, numOfNodes, t);
    }

    free(recvCounts);
    free(r);
    MPI_Finalize();
    return 0;
}

void syncSharedArrays(double *contribution, double *r, int *recvCounts, int *startPartitions) {
    MPI_Allgatherv(MPI_IN_PLACE, 0, MPI_DOUBLE, contribution, recvCounts, startPartitions, MPI_DOUBLE, MPI_COMM_WORLD);
    MPI_Allgatherv(MPI_IN_PLACE, 0, MPI_DOUBLE, r, recvCounts, startPartitions, MPI_DOUBLE, MPI_COMM_WORLD);
}

double *iterate(
        struct node *nodehead,
        int myNodeCount,
        int totalNodeCount,
        int myRank,
        int *recvCounts,
        int *startPartitions,
        int *endPartitions) {
    double *r, *r_pre, *contribution;
    int i, j;
    int offset_i = startPartitions[myRank], offset_j = endPartitions[myRank];
    double damp_const;
    int iterationcount = 0;

    // initialize variables
    r = malloc(totalNodeCount * sizeof(double));
    r_pre = malloc(totalNodeCount * sizeof(double));
    for ( i = 0; i < myNodeCount; ++i)
        r[i + offset_i] = 1.0 / totalNodeCount;

    contribution = malloc(totalNodeCount * sizeof(double));
    for ( i = 0; i < myNodeCount; ++i)
        contribution[i + offset_i] = r[i + offset_i] / nodehead[i].num_out_links * DAMPING_FACTOR;

    syncSharedArrays(contribution, r, recvCounts, startPartitions);

    damp_const = (1.0 - DAMPING_FACTOR) / totalNodeCount;
    do{
        ++iterationcount;
        vec_cp(r, r_pre, totalNodeCount);
        // update the value
        for ( i = 0; i < myNodeCount; ++i){
            r[i + offset_i] = 0;
            for ( j = 0; j < nodehead[i].num_in_links; ++j)
                r[i + offset_i] += contribution[nodehead[i].inlinks[j]];
            r[i + offset_i] += damp_const;
        }
        // update and broadcast the contribution
        for ( i=offset_i; i<offset_j; ++i){
            contribution[i] = r[i] / nodehead[i - offset_i].num_out_links * DAMPING_FACTOR;
        }
        syncSharedArrays(contribution, r, recvCounts, startPartitions);
    }while(rel_error(r, r_pre, totalNodeCount) >= EPSILON);

    // post processing
    node_destroy(nodehead, myNodeCount);
    free(contribution);
    free(r_pre);

    return r;
}

int getNodeCount(){
    int nodecount;
    FILE* ip;
    if ((ip = fopen("data_input_meta","r")) == NULL) {
        printf("Error opening the data_input_meta file.\n");
        abort();
    }
    fscanf(ip, "%d\n", &nodecount);
    fclose(ip);
    return nodecount;
}

int getEdgeCount(struct node* headNode, int numOfNodes){
    int numOfEdges = 0;
    for(int i = 0; i < numOfNodes; i++){
        numOfEdges += headNode[i].num_in_links;
    }
    return numOfEdges;
}

void splitVectorIntoPartitions(int numOfProcesses, int numOfEdges, int numOfNodes, 
                                 struct node* headNode, int** startPartition, 
                                 int** endPartition){
    
    int balancedWeightTarget = numOfEdges/numOfProcesses;
    int partitionCurrentWeight = 0;
    int indexCounter = 0;

    for(int i = 0; i < numOfProcesses; i++){
        (*startPartition)[i] = indexCounter;
        while(partitionCurrentWeight < balancedWeightTarget && indexCounter < numOfNodes){
            partitionCurrentWeight += headNode[indexCounter].num_in_links;
            indexCounter++;
        }
        partitionCurrentWeight = 0;
        (*endPartition)[i] = indexCounter;
    }

}