#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>

#define BLOCK_SIZE 128000
#define WINDOWSIZE 1000000

void verifyArguements(int, char*[], int*, int*, bool*);
void runForProgram(int, int, bool);
int readFromStream(int, char*, int);
int writeToStream(int, char*, int);
char* getLine(char*);
bool isValidLine(char*, bool);
void initHashTable(int windowSize);
struct Node *search(int pageSize, char* key);
void insert(int pageSize, char* key, int value);
unsigned int hashPage(int pageSize, char* key);
char* getMemAddress(char* workingLine);
struct list* createList(int val);
struct list* addToList(int val, bool end);
int listSearch(int val, struct list **prev);
int delete();
void printLinkList(void);
int calculateWorkingSet(unsigned int addVal, unsigned int delVal);
void plottingWS();

int counter = 0;
int workingSet = 0;
int num = 0;

struct list {
  int val;
  struct list *next;
};
struct list *head = NULL;
struct list *curr = NULL;

int main(int argc, char* argv[]){
  int pageSize;
  int windowSize;
  bool ignoreInstructionFetch;

  verifyArguements(argc, argv, &pageSize, &windowSize, &ignoreInstructionFetch);

  //The below line is the basis of how to run a program to be analyzed by Lackey
  runForProgram(pageSize, windowSize, ignoreInstructionFetch);

  //plottingWS();

  return 0;
}

/*
 * Quickly verifies the arguements passed to the program form the terminal.
 * If anything is found to be out of order the program will exit gracefully.
 * Additionally converts pageSize and windowSize variables from chars to ints.
 *
 * @param int argc - The number of arguements passed.
 * @param char* argv[] - Contains an array of the string pointers of the arguements.
 * @param int* pageSize - The pageSize used to process the instruction address.
 * @param int* windowSize - The windowSize used to process the instructions.
 * @param bool* ignoreInstructionFetch - Effectively a boolean, a flag that
 *                                       states if instruction fetches should be
 *                                       ignored or included in calculations.
 *                                       0 - Ignore
 */
void verifyArguements(int argc, char* argv[], int* pageSize, int* windowSize, bool* ignoreInstructionFetch){
  *ignoreInstructionFetch = false;

  if(argc != 3 && argc != 4){
    printf("Invalid number of parameters.");
    exit(1);
  }
  if(argc == 4){
    if(argv[1][0] == '-' && argv[1][1] == 'i'){
      //printf("Ignoring all instruction fetches.\n");
      *ignoreInstructionFetch = true;
    }else{
      printf("Unknown Parameter: %s\n", argv[1]);
      exit(1);
    }
  }

  *pageSize = atoi(argv[1 + *ignoreInstructionFetch]);
   int pageSizeCounter = 16;

  //If pageSize is zero (due to invalid string for example) altering the counter
  //instead provides some level of protection from an infinite loop.
  while(pageSizeCounter != *pageSize){
    pageSizeCounter *= 2;
    if(pageSizeCounter > 65536){
      printf("Page size is invalid.\n");
      exit(1);
    }
  }

  *windowSize = atoi(argv[2 + *ignoreInstructionFetch]);
  if(*windowSize <= 0){
    printf("Invalid window size.\n");
    exit(1);
  }

}

/*
 * Sets up Valgrind/Lackey with the requested paramter settings and the program
 * that is to be run through Valgrind/Lackey. Then processes the output from
 * Valgrind/Lackey and saves it to a file, later to be run through gnuplot.
 *
 * This is an artifact of the first version that was written. The code in here
 * could be moved to main().
 *
 * @param char* programName - The program that is to be run through Valgrind/Lackey.
 *                            The output file name is:
 *                            programName + pageSize + '-' + windowSize.dat file extension.
 * @param char* programArgs - Optional Args to be passed to the program.
 * @param int pageSize - The page size used to process data.
 * @param int windowSize - The window size used to process data.
 * @param int ignoreInstructionFetch - A flag used to either process or ignore
 *                                      instruction fetch lines.
 */
void runForProgram(int pageSize, int windowSize, bool ignoreInstructionFetch){
  //File or String variables
  char *outputFileName = (char*)calloc(255, 1); //Max file name length as per UNIX
  char *readBuffer = (char*)calloc(BLOCK_SIZE, 1);
  char *writeBuffer = (char*)calloc(BLOCK_SIZE, 1);
  int offset = 0;
  bool needMoreData = false; //Used to get around using a break statement
  //FILE *wsTextFile = fopen("wsTextFile.txt", "w");

  //We are going to be printing a lot potentially. Lets hold off printing
  //Until we have ALOT of data to put out. I feel this is safe as the data
  //Is not critical should the system fail for whatever reason.
  sprintf(outputFileName, "lackeyOutput_%d_%d", pageSize, windowSize);
  if(ignoreInstructionFetch){
    strcat(outputFileName, "I.dat");
  }else{
    strcat(outputFileName, ".dat");
  }
  FILE *outputFile = fopen(outputFileName, "w+"); //Output our contents here

  if(outputFile == NULL){
    perror("Ouput File failed to open.\n");
    exit(3);
  }

  int bytesRead = 1;

  while(bytesRead){
    //Minus one guarentees that we will have a zero at the end of the buffer.
    bytesRead = readFromStream(STDIN_FILENO, readBuffer + offset, BLOCK_SIZE - offset - 1);
    needMoreData = false;
    offset = 0;

    unsigned int delVal;
    int newWorkingSet;
    while(!needMoreData){
      char* workingLine = getLine(readBuffer + offset);
      if(workingLine != NULL){
        offset += strlen(workingLine);

        //I figured it makes more sense to have the logic here instead of getline()
        //as get line should only care about getting char bytes until the next \n
        //it encounters.
        if(isValidLine(workingLine, ignoreInstructionFetch)){
          //writeBuffer = strcat(writeBuffer, workingLine);
          char str[20];
          strcpy(str, workingLine);
          char* newstr = strtok(str, " ");
          newstr = strtok(NULL, " ");
          newstr = strtok(newstr, ",");
          //printf("MEM ADDRESS: %s\n", newstr);
          unsigned int bashKey = hashPage(pageSize, newstr);
          int value = 1;
          bool ws;
          if (counter != windowSize){
            delVal = -1;
            newWorkingSet = calculateWorkingSet(bashKey, -1);
            addToList(bashKey, true);
            ++counter;
          } else if (counter == windowSize) {
            newWorkingSet = calculateWorkingSet(bashKey, -1);
            addToList(bashKey, true);
            delVal = delete();
            newWorkingSet = calculateWorkingSet(delVal, -2);
            counter = windowSize;
          }
          //printf("KEY: %d\n", bashKey);
          //printf("Deleted Value: %d\n", delVal);
          //printf("%s",workingLine);
          //printf("Working Set %d %d\n", num, newWorkingSet);
          fprintf(outputFile, "%d %d\n", num, newWorkingSet); //CHANGE ME
          ++ num;
          //printLinkList();
        }

        //Output in chunks, otherwise the program will take forever to complete
        //Due to blocking&unblocking constantly. We should maybe play around
        //with the numbers. Maybe have it equal to BLOCK_SIZE as well however
        //that might cause some unintentional issues.
        //BLOCK_SIZE-200 selected arbitrarily such that our buffer doesnt run out of space.
        //Mathematically it looks messey but I dont think it is the worst solution in the world.
        //if(strlen(writeBuffer) >= BLOCK_SIZE - 200){
        //  writeToStream(fileno(outputFile), writeBuffer, strlen(writeBuffer));
        //  memset(writeBuffer, 0, BLOCK_SIZE);
        //}
      }else{
        //Read buffer has run out of data or doesnt have a partial line.
        //Move the line over to the beginning and read in another chunk of
        //data from the pipe.
        needMoreData = true;
        memcpy(readBuffer, readBuffer + offset, strlen(readBuffer + offset)); //Move the remainder of the buffer to the front of the read buffer.
        offset = strlen(readBuffer + offset); //Make out offset the remainder of what is in our buffer
        memset(readBuffer + offset + 1, 0, BLOCK_SIZE - offset - 1); //Clear out our readBuffer
      }
      free(workingLine); //We no longer need our current Line that we are dealing with
    }
  }
  //Write the rest of the data now that our file is empty.
  //writeToStream(fileno(outputFile), writeBuffer, strlen(writeBuffer));

  //Free up all our stuff, do we need all of these variables for processing???
  free(outputFileName); //Yes, we need this dynamically allocated to modify the string for filename
  free(readBuffer); //Yes, for reading in data from pipe.
  free(writeBuffer);  //Yes, for writing processed data to file.
  fflush(outputFile);
  //fsync(fileno(outputFile));
  close(fileno(outputFile));
  //fsync(fileno(wsTextFile));
  //fclose(wsTextFile);
}

/*
 * Reads in a chunk of data from a file descriptor.
 * For the purpose of this program it reads in data from a pipe setup with
 * Valgrind/Lackey writing into it.
 *
 * @param int fd - The file descriptor to read data from the pipe.
 * @param char* readBuffer - Where to store the data that was read from the pipe.
 * @param int readLength - How many bytes to read from at most.
 *
 * @return int bytesRead - Returns the number of bytes that have been read from
 *                         the file descriptor.
 */
int readFromStream(int fd, char* readBuffer, int readLength){
  int bytesRead = read(fd, readBuffer, readLength);
  if(bytesRead == -1){
    perror("Read error: ");
    exit(3);
  }
  return bytesRead;
}

/*
 * Obsolete - replaced by fprintf()
 *
 * Writes data to a file after processing the read data from Valgrind/Lackey.
 * The writing should be done in a buffer, chunk by chunk instead of
 * line by line as the overhead from fsync() will render writing out the file
 * to be painfully slow.
 *
 * @param int fd - The file descriptor that points to a file to save the output
 *                 data after being processed from Valgrind/Lackey.
 *
 * @return int bytesWritten - Returns the number of bytes written to the file
 *                            descriptor.
 */
int writeToStream(int fd, char* writeBuffer, int writeLength){
  int bytesWritten = write(fd, writeBuffer, writeLength);
  if(fsync(fd) == -1 || bytesWritten == -1){ //Ensure everything is written to the file
    perror("Write error: ");
    exit(3);
  }
  return bytesWritten;
}

/*
 * This function takes in a pointer to a buffer that should have character data
 * in it and returns the characters upto and including a newline character.
 * Think of returning a null-terminated string but with a newline instead of a
 * null character. If there is not a complete line then ignore it and return
 * NULL pointer. The calling function should implement logic to either ignore
 * this data or carry it over with more data being fetched.
 *
 * @param char* writeBuffer - The buffer looked at to find a string.
 *
 * @return char* currentLine - Returns a copy of the string found in writeBuffer
 *                             that is null terminated. Returns a NULL pointer
 *                             if there isnt a complete line in the buffer.
 */
char* getLine(char* writeBuffer){
  char* endOfLine = strchr(writeBuffer,'\n');
  char* currentLine = (char*)calloc(100, 1); //Reserving 100 bytes of memory is more than needed, but should be safe
  int bufferLength = strlen(writeBuffer); //The length of the total buffer
  int messageLength; //Used to calculate how many bytes we need from the buffer

  if(endOfLine == NULL){
    return NULL;
  }

  messageLength = endOfLine - writeBuffer + 1; //+1 to include the \n char
  currentLine = memcpy(currentLine, writeBuffer, messageLength); //Get the line

  return currentLine;
}

/*
 * Should a line be processed or ignored. Lackey comments are ignored as well
 * if -i was declared then the program should ignore instruction fetchs as well.
 *
 * Lackey follows a standard output so designing for arbitrary input seems
 * unnessesary. If checking for desired input the logic in this function would
 * be considerably more complex, having to verify: A valid memory access type,
 * a valid memory address, and a valid size.
 *
 * @param char* workingLine - The current line that is in preprocessing.
 * @param bool ignoreInstructionFetch - True is -i was passed in command-line
 *                                      False otherwise.
 *
 * @return Returns true if the line should be processed. Returns false otherwise.
 */
bool isValidLine(char* workingLine, bool ignoreInstructionFetch){
  if((*workingLine == '=' && *(workingLine + 1) == '=')
      || (ignoreInstructionFetch && *workingLine == 'I')){
    return false;
  }
  return true;
}

unsigned int hashPage(int pageSize, char* key){
  unsigned int temp = pageSize;
  char *eptr;
  unsigned long result;
  char value[20];
  strcpy(value, key);
  //printf("Value: %s\n", value);
  result = strtoul(value, &eptr, 16);
  //printf("DECIMAL FORM: %lu\n", result);
  return (result % temp);
}

struct list* createList(int val){
  struct list *ptr = (struct list*)malloc(sizeof(struct list));
  if(NULL == ptr){
    //printf("Node creation failed");
    return NULL;
  }
  ptr->val = val;
  ptr->next = NULL;
  head = curr = ptr;
  return ptr;
}

struct list* addToList(int val, bool end){
  if (NULL == head){
    return createList(val);
  }
  struct list *ptr = (struct list*)malloc(sizeof(struct list));
  if(NULL == ptr){
    //printf("Node creation failed");
    return NULL;
  }
  ptr->val = val;
  ptr->next = NULL;

  if(end) {
    curr->next = ptr;
    curr = ptr;
  } else {
    ptr->next = head;
    head = ptr;
  }
  return ptr;
}

int listSearch(int val, struct list **prev){
    struct list *ptr = head;
    struct list *tmp = NULL;
    bool found = false;

    while(ptr != NULL){
      if (ptr->val == val){
        found = true;
        break;
      } else {
        tmp = ptr;
        ptr = ptr->next;
      }
    }
    if (found){
      if (prev){
        *prev = tmp;
        return 1;
      }
    } else {
      return 0;
    }
}

int delete(){
    //struct list *del = NULL;
    struct list *temp = head;
    int del = head->val;
    temp = temp->next;
    free(head);
    head = temp;
    return del;
}

void printLinkList(void)
{
    struct list *ptr = head;

    printf("\n -------Printing list Start------- \n");
    while(ptr != NULL)
    {
        printf("\n [%d] \n",ptr->val);
        ptr = ptr->next;
    }
    printf("\n -------Printing list End------- \n");

    return;
}

int calculateWorkingSet(unsigned int val, unsigned int delVal){
  bool ws;
  ws = listSearch(val, NULL);
  if (delVal == -1){
    if (ws == 0){
      ++workingSet;
    }

  } else if (delVal == -2){
    if (ws == 0){
      --workingSet;
    }
  }

  return workingSet;
}

void plottingWS(){
  printf("here");
  FILE *wsData;
  FILE *pipefile;
  //char filepath ='/home/users/CMPUT379/CMPUT379A1/Assignment3/wsTextFile2.data';
  //wsData = fopen('wsTextFile.txt', "r");
  pipefile = popen("gnuplot -persistent", "w");
  fprintf(pipefile, "set title 'Working Set Data'\n");
  fprintf(pipefile, "set xlabel 'X'\n");
  fprintf(pipefile, "set ylabel 'Working Set'\n");
  fprintf(pipefile, "set output 'graph.png'\n");
  fprintf(pipefile, "plot '/home/users/CMPUT379/CMPUT379A1/Assignment3/wsTextFile.txt' using 0:1\n");
  fclose(pipefile);

}
