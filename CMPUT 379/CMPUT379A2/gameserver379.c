#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <signal.h>
#include <string.h>

#define SERVER_ADDRESS "127.0.0.1"
#define NUM_SERVER_ARGS 5
#define GAME_DIMENSION atoi(argv[1])
#define UPDATE_PERIOD atof(argv[2])
#define PORT_NUMBER atoi(argv[3])
#define SRAND_SEED atoi(argv[4])

void verifyArguements();
void setupSignals();
void setupServer();
void shutdownServer();


/*
1) create socket
2) Set server info in struct sockaddr_in
3) bind socket identifier
4) listen for connections
5) accept incoming connections
*/
int main(int argc, char* argv[]){
  struct sigaction sigTermSignal;
  struct sockaddr_in* serverSocket = (struct sockaddr_in*)malloc(sizeof(struct sockaddr_in));
  struct sockaddr_in* incomingSocket = (struct sockaddr_in*)malloc(sizeof(struct sockaddr_in));
  int incomingSocketSize = sizeof(*incomingSocket);
  char* readBuffer = (char*)calloc(1024, 1);

  if(readBuffer == NULL){
    printf("Failed to allocate buffer.");
    exit(2);
  }

  verifyArguements(argc, argv);
  setupSignals(sigTermSignal);
  //setupServer();
  //Currently left in main until we figure out where to put it

  int socketFD = socket(PF_INET, SOCK_STREAM, 0);
  serverSocket->sin_family = AF_INET;
  serverSocket->sin_port = htons(PORT_NUMBER);
  if(!inet_aton(SERVER_ADDRESS, &serverSocket->sin_addr)){
    printf("Internal error. Invalid server address.\n");
    exit(2);
  }

  if(bind(socketFD, serverSocket, sizeof(*serverSocket))){
    perror("Server Bind Failed:");
    exit(2);
  }

  //GAME_DIMENSION^2 provides the absolute maximum number of initial connections
  //As players cannot share a square. This has the potential to provide a very
  //poor game experience.
  if(listen(socketFD, GAME_DIMENSION*GAME_DIMENSION)){
    perror("Server Listen Failed:");
    exit(2);
  }
  //Should each player have its own socket struct?
  int acceptedSocketFD = accept(socketFD, incomingSocket, &incomingSocketSize);
  char* testMsg = "Server says Hi to client";
  send(acceptedSocketFD, testMsg, strlen(testMsg) + 1, 0);
  recv(acceptedSocketFD, readBuffer, 1024, 0);

  printf("%s\n", readBuffer);

  close(acceptedSocketFD);

  printf("END Server.\n");
  return 0;
}

void verifyArguements(int argc, char* argv[]){
  if(argc != NUM_SERVER_ARGS){
    printf("Invalid number of arguments provided. The server requires %d arguments in total: \n", NUM_SERVER_ARGS);
    printf("client/server, board dimension, period, port, and a seed.\n");
    exit(1);
  }

  if(GAME_DIMENSION < 1){//Board dimension
    printf("Invalid board dimensions.\nDimensions must be greater than zero.\n");
    exit(1);
  }

  if(UPDATE_PERIOD <= 0.0){ //Time Period
    printf("Invalid update period.\nUpdate period must be greater than zero.\n");
    exit(1);
  }

  int portNumber = PORT_NUMBER; //Port Number
  if(portNumber <= 1024 || portNumber > 65535){
    if(portNumber == 0){
      printf("The port number provided is either invalid or asking the kernel to assign a random port.\n");
    }else{
      printf("Invalid Port Number.\nThe port number is out of range or is reserved.\n");
    }
    exit(1);
  }

  if(SRAND_SEED == 0){//Random seed
    printf("WARNING: The seed is either zero or read in incorrectly.\n");
    printf("If the desired seed is zero ignore this message.\n");
  }


}

void setupSignals(struct sigaction sigTermSignal){
  sigTermSignal.sa_sigaction = &shutdownServer;
  sigTermSignal.sa_flags = SA_SIGINFO;
  if(sigaction(SIGTERM, &sigTermSignal, NULL) < 0){
    perror("SIGTERM setup error.");
    exit(2);
  }
}

void setupServer(struct sockaddr_in serverSocket){
  //Move server setup code here.
}

void shutdownServer(){
  printf("Goodbye. We should probably broadcast to clients that the\n");
  printf("server is shutting down.\n");

  exit(0);
}
