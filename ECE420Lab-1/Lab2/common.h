#ifndef LAB2_COMMON_H_
#define LAB2_COMMON_H_

#include <string.h>
#include <stdlib.h>
#include <stdio.h>


/* Important parameters */
// Change these if needed
#define COM_IS_VERBOSE 0 // 0 off; 1 on
// Do not change the following for your final testing and submitted version
#define COM_NUM_REQUEST 1000 // Number of total request
                    // For ease of implementation, prepare this many threads in server to handle the request
#define COM_BUFF_SIZE 100 // communication buffer size, which is the maximum size of the transmitted string
#define COM_CLIENT_THREAD_COUNT 100 // Number of threads in client, COM_NUM_REQUEST should be divisible by this Number
//-------------------------------------
// Server utilities

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

typedef struct{
    int pos; 
    int is_read;
    char msg[COM_BUFF_SIZE];
} ClientRequest; // To store the parsed client message

int ParseMsg(char* msg, ClientRequest* rqst);
void setContent(char* src, int pos, char **theArray);
void getContent(char* dst, int pos, char **theArray);
void saveTimes(double* time, int length);
void initMsgArr(int num_msgs, char ***theArray);
void freeMsgArr(int num_msgs, char **theArray);

#endif


