#include "common.h"


// parse the massage from client and get the control info and message info
// Input: msg: message string with format "pos-is_read-XXXXXXX"
//        rqst: previously allocated stucture to store the parsed result 
int ParseMsg(char* msg, ClientRequest* rqst){
    char *token;
    token = strsep(&msg, "-");
    rqst->pos = atoi(token);
    token = strsep(&msg, "-");
    rqst->is_read = atoi(token);
    token = strsep(&msg, "-");
    memcpy(rqst->msg, token, strlen(token)+1);
    return 0;
}

// Function to set the server string array
// Input: src: source string to save
//        pos: position to be changed
//        theArray: server string array
void setContent(char* src, int pos, char **theArray){
    int i;
    char *dst = theArray[pos];
    int length = MIN(strlen(src)+1, COM_BUFF_SIZE);
    for (i=0; i<length; ++i){
        dst[i] = src[i];
    }
}

// Function to get the server string array
// Input: dst: dst string buffer to get the server content
//        pos: position to be get 
//        theArray: server string array
void getContent(char* dst, int pos, char **theArray){
    int i;
    char *src = theArray[pos];
    int length = MIN(strlen(src)+1, COM_BUFF_SIZE);
    for (i=length-1;i>=0; --i ){
        dst[i] = src[i];
    }
}

// Function to save the measured time
// Input: time: pointer to the array that store the time for each request
//        length: length of the time
void saveTimes(double* time, int length){
    FILE* op;
    int i;
    double elapsed_time = 0;
    // if ((op = fopen("server_output_request_time","a+")) == NULL){
    //     printf("Error opening the output file: server_output_request_time.\n");
    //     exit(1);
    // }
    // for (i=0; i<length; ++i){
    //     fprintf(op, "%e\n", time[i]);
    //     elapsed_time += time[i];
    // }
    // fclose(op);
    if ((op = fopen("server_output_time_aggregated","a+")) == NULL){
        printf("Error opening the output file: server_output_time_aggregated.\n");
        exit(1);
    }
    fprintf(op, "%.9f\n", *time);
    fclose(op);
}

void initMsgArr(int num_msgs, char ***theArrayOut) {
  char **theArray = (char**) malloc(num_msgs * sizeof(char*));
  for (int i = 0; i < num_msgs; i ++){
    //theArray[i] = (char*) malloc(num_msgs * sizeof(char));
    theArray[i] = (char*) malloc(COM_BUFF_SIZE * sizeof(char));
    sprintf(theArray[i], "String %d: initial value", i);
  }
  *theArrayOut = theArray;
}

void freeMsgArr(int num_msgs, char **theArray) {
  for (int i=0; i<num_msgs; ++i){
    free(theArray[i]);
  }
  free(theArray);
}