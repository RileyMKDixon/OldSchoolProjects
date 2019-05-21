#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <pthread.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "common.h"
#include "timer.h"
#include "lockedMsgArray.h"
#include <stdbool.h>

typedef struct client_info{
    msg_arr_t msgs;
    int clientSocketFD;
    pthread_t threadHandle;
    bool running;
}client_info_t;

void *clientListener(void* args){
    client_info_t* ci = (client_info_t*)args;
    double startTime = 0.0;
    double endTime = 0.0;

    ClientRequest* requestReceived = (ClientRequest*)calloc(1, sizeof(ClientRequest));
    char msgReceived[COM_BUFF_SIZE] = {0};
    char* stringBuf = (char*)calloc(COM_BUFF_SIZE, sizeof(char));
    if(read(ci->clientSocketFD, msgReceived, COM_BUFF_SIZE) == -1){
        printf("READ ERROR\n");
        exit(9);
    }

    GET_TIME(startTime);

    ParseMsg(msgReceived, requestReceived);
    
    if(!requestReceived->is_read){
        setContentLocked(requestReceived->msg, requestReceived->pos, &(ci->msgs));
        strcpy(stringBuf, requestReceived->msg);
    }else{
        getContentLocked(stringBuf, requestReceived->pos, &(ci->msgs));
    }
    
    GET_TIME(endTime);

    write(ci->clientSocketFD, stringBuf, COM_BUFF_SIZE);
    free(requestReceived);
    free(stringBuf);
    close(ci->clientSocketFD);

    double* result = calloc(1, sizeof(double));
    *result = endTime - startTime;
    pthread_exit(result);
}

int main(int argc, char* argv[]) {
    struct sockaddr_in* serverSocket = malloc(sizeof(struct sockaddr_in));
    int serverSocketFD=socket(AF_INET,SOCK_STREAM,0);

    int numOfStringsInArray = atoi(argv[1]);
    if(inet_aton(argv[2], &(serverSocket->sin_addr)) == 0){
        printf("inet_aton() failed.\n");
        exit(1);
    }
    serverSocket->sin_port = atoi(argv[3]);
    serverSocket->sin_family=AF_INET;
    printf("Port: %d\n", serverSocket->sin_port);

    msg_arr_t msgArray = initLockedMsgArr(numOfStringsInArray);

    //Define the implementation type of the array here.


    int clientSocketFileDescriptor;
    client_info_t* clients;
    if(bind(serverSocketFD,(struct sockaddr*)serverSocket,sizeof(*serverSocket))>=0){
        printf("socket has been created\n");
        if(listen(serverSocketFD,2000) != 0){
            printf("Listen() Failed.\n");
            exit(2);
        } 


        int runNum = 0;
        double runTimeAverage = 0.0;
        while(runNum < 100){        //loop infinity
            clients = (client_info_t*)calloc(COM_NUM_REQUEST, sizeof(client_info_t));
            double memoryAccessTimeTotal = 0.0;
            if(clients == 0){
                printf("calloc failed\n");
                exit(6);
            }

            for(int i=0;i<COM_NUM_REQUEST;i++){      //can support COM_NUM_REQUEST clients at a time
                clientSocketFileDescriptor=accept(serverSocketFD,NULL,NULL);
                if(clientSocketFileDescriptor == -1){
                    perror("Error is: \n");
                    exit(5);
                }
                //printf("NumRun: %d  COM_REQUEST: %d\n", runNum, i);

                clients[i].clientSocketFD = clientSocketFileDescriptor;
                clients[i].msgs = msgArray;
                int err = pthread_create(&(clients[i].threadHandle),NULL,clientListener,(void *)&clients[i]);
                if(err != 0){
                    printf("pthread_create error\n");
                    exit(7);
                }
            }
            for(int i=0;i<COM_NUM_REQUEST; i++){
                double *memoryAccessTime;
                int threadResult = pthread_join(clients[i].threadHandle, (void**)&memoryAccessTime);
                if(threadResult != 0){
                    printf("Thread exited with %i\n", threadResult);
                    exit(3);
                }
                memoryAccessTimeTotal += *memoryAccessTime;
                free(memoryAccessTime);

            }
            saveTimes(&memoryAccessTimeTotal, 9);
            runTimeAverage += memoryAccessTimeTotal;
            free(clients);
            runNum++;
        }
        runTimeAverage /= 100;
        saveTimes(&runTimeAverage, 9);
        close(serverSocketFD);
    }
    else{
        printf("socket bind creation failed\n");
    }
    free(serverSocket);
    return 0;
}