/*
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <string.h>
#include <ncurses.h>
#include "player.h"

#define NUM_CLIENT_ARGS 3
#define OUTGOING_ADDRESS argv[1]
#define PORT_NUMBER atoi(argv[2])

#define BOARD_DIMENSION 20

//char command;
//enum command {LEFT = 'j', UP = 'i', RIGHT = 'l', DOWN = 'k', FIRE = ' '};

void verifyArguements();
void setupConnection();
void testMsg();
void getInput();
void outputToScreen();
void initializeScreen();
char printPlayerDirection();
void quitGame();
void printFire();

int main(int argc, char* argv[]){
  struct player_t* dumbPlayer = (struct player_t*)calloc(1, sizeof(struct player_t));
  dumbPlayer->xCoordinate = 0;
  dumbPlayer->yCoordinate = 0;

  struct sockaddr_in* clientSocket;
  int socketFD = socket(PF_INET, SOCK_STREAM, 0);
  WINDOW* borderWindow;
  WINDOW* mapWindow;
  WINDOW* commandWindow;
  //int borderMaxX; //Possibly not needed if map dimensions known
  //int borderMaxY; //Possibly not needed if map dimensions known

  char* readBuffer = (char*)calloc(1024, 1); //TODO: Consider placement? Where does this need to be?

  verifyArguements(argc, argv);
  //setupConnection(clientSocket, argv, socketFD);

  initializeScreen(BOARD_DIMENSION, &borderWindow, &mapWindow, &commandWindow);
  /*
  initscr();
  cbreak();
  noecho();
  //borderWindow = newwin(LINES-1, COLS, 0, 0); //LINES and COLS should be changed to map dimensions + 1
  borderWindow = newwin(BOARD_DIMENSION+2, BOARD_DIMENSION+2, 0, 0); //Plus 2 to account for the border
  getmaxyx(borderWindow, borderMaxY, borderMaxX); //Possibly not needed if map dimensions known
  mapWindow = newwin(borderMaxY-2, borderMaxX-2, 1, 1); //start off of the corner
  commandWindow = newwin(1, COLS, LINES-1, 0);
  refresh(); //Allows our windows to be placed in the terminal and then manipulated

  //Prints a border.
  box(borderWindow, 0, 0);
  wrefresh(borderWindow);
  mvwprintw(mapWindow, dumbPlayer->yCoordinate, dumbPlayer->xCoordinate, "^");
  wrefresh(mapWindow);
  */

  //Prints the initial character. Needs to be rpelaced with SRAND()
  mvwprintw(mapWindow, dumbPlayer->yCoordinate, dumbPlayer->xCoordinate, "^");
  wrefresh(mapWindow);

  while(true){
    getInput(mapWindow, commandWindow, borderWindow, dumbPlayer);
    outputToScreen();
    wrefresh(mapWindow);

  }
  endwin();


  //testMsg(socketFD, readBuffer);

  //close(socketFD);

  printf("END Client.\n");
  return 0;
}

/*
 *
 *
 */
void verifyArguements(int argc, char* argv[]){

  if(argc != NUM_CLIENT_ARGS){
    printf("Invalid number of arguements received for client.\n");
    exit(1);
  }

  //connect to the server.
  //The IP Address will be verified later in the process when trying to

  int portNumber = PORT_NUMBER; //Port Number
  if(portNumber <= 1024 || portNumber > 65535){
    if(portNumber == 0){
      printf("The port number provided is either invalid or asking the kernel to assign a random port.\n");
    }else{
      printf("Invalid Port Number.\nThe port number is out of range or is reserved.\n");
    }
    exit(1);
  }
}

/*
 *
 *
 */
void setupConnection(struct sockaddr_in* clientSocket, char* argv[], int socketFD
                    ){
  clientSocket = (struct sockaddr_in*)malloc(sizeof(struct sockaddr_in));
  clientSocket->sin_family = AF_INET;
  clientSocket->sin_port = htons(PORT_NUMBER);
  if(!inet_aton(OUTGOING_ADDRESS, &clientSocket->sin_addr)){
    printf("Internal error. Invalid server address.\n");
    exit(2);
  }

  if(connect(socketFD, clientSocket, sizeof(*clientSocket))){
    perror("Client connection failed.");
    exit(2);
  }

}

/*
 *
 *
 */
void testMsg(int socketFD, char* readBuffer){
  char* testMsg = "Client says Hi to server";
  send(socketFD, testMsg, strlen(testMsg) + 1, 0);
  recv(socketFD, readBuffer, 1024, 0);
  printf("%s\n", readBuffer);
}

/*
 * Sets up additional windows to organize our outputs. The WINDOW parameters
 * are pointers to pointers in order to psuedo pass-by-reference so that their
 * values in main are updated accordingly.
 *
 * @param int boardDimension -- The length of the board. Given that the board is
 *                              square this is both the length and the width.
 * @param WINDOW** borderWindow -- This WINDOW is used exclusively for showing
 *                                 the border of the game board. It isn't used
 *                                 for anything else.
 * @param WINDOW** mapWindow -- This WINDOW is used for updating the actual game
 *                              map. Most output activity will involve this
 *                              WINDOW. Shows other players and firing actions.
 * @param WINDOW** commandWindow -- Used to show the players last pressed
 *                                  button. This is what will be sent to the
 *                                  server. Can also be used for debugging to
 *                                  the screen if desired.
 *
 */
void initializeScreen(int boardDimension, WINDOW** borderWindow,
                      WINDOW** mapWindow, WINDOW** commandWindow){
  int borderMaxX;
  int borderMaxY;

  //Initialize a ncurse window
  initscr(); //Initialize ncurses
  cbreak(); //
  noecho(); //No echo from stdinput
  curs_set(0); //Make cursor invisible

  //Initialize our windows that we will use
  *borderWindow = newwin(boardDimension + 2, boardDimension + 2, 0, 0); //Plus 2 to account for the border
  getmaxyx(*borderWindow, borderMaxY, borderMaxX); //Possibly not needed if map dimensions known
  *mapWindow = newwin(borderMaxY-2, borderMaxX-2, 1, 1); //start off of the corner
  *commandWindow = newwin(1, COLS, LINES-1, 0);
  refresh(); //Allows our windows to be placed in the terminal and then manipulated
  //Refresh() is necessary to update stdscr, otherwise we are unable to manipulate
  //the borderWindow or anything else;

  //Prints a border on border window.
  box(*borderWindow, 0, 0);
  wrefresh(*borderWindow);

  //Prints the initial character. Needs to be rpelaced with SRAND()
  //Also player updating should happen in a different function right?
  //As info comes from the server.
  //mvwprintw(mapWindow, dumbPlayer->yCoordinate, dumbPlayer->xCoordinate, "^");
  // /wrefresh(mapWindow);
}

/*
 *
 *
 */
void getInput(WINDOW* mapWindow, WINDOW* commandWindow, WINDOW* borderWindow, struct player_t* player){
  char ch = getch();
  werase(commandWindow);
  mvwprintw(commandWindow, 0, 0, "Command: ");
  //TODO: Get the enum'd variables compaitble to reading out of a player struct?
  switch(ch){
    case MOVING_LEFT:
      moveLeft(player, BOARD_DIMENSION);
      wprintw(commandWindow, "%c", MOVING_LEFT);
      break;
    case MOVING_UP:
      moveUp(player, BOARD_DIMENSION);
      wprintw(commandWindow, "%c", MOVING_UP);
      break;
    case MOVING_RIGHT:
      moveRight(player, BOARD_DIMENSION);
      wprintw(commandWindow, "%c", MOVING_RIGHT);
      break;
    case MOVING_DOWN:
      moveDown(player, BOARD_DIMENSION);
      wprintw(commandWindow, "%c", MOVING_DOWN);
      break;
    case FIRE:
      player->lastCommand = FIRE;
      wprintw(commandWindow, "FIRE");
      printFire(player, mapWindow);
      break;
    case QUIT:
      player->lastCommand = QUIT;
      wprintw(commandWindow, "%c", QUIT);
      break;
    default:
    wprintw(commandWindow, "INVALID COMMAND");
  }

  //werase(mapWindow); //Replace with what the server says or something.
  mvwprintw(mapWindow, player->yCoordinate, player->xCoordinate, "%c", printPlayerDirection(player));
  wrefresh(mapWindow);

  //werase(commandWindow);
  //mvwprintw(commandWindow, 0, 0, "X:%d Y:%d", player->xCoordinate, player->yCoordinate);
  wrefresh(commandWindow);
}

/*
 *
 */
char printPlayerDirection(struct player_t* player){
  return player->currentDirection;
}

/*
 *
 */
void printFire(struct player_t* player, WINDOW* mapWindow){
  switch(player->currentDirection){
    case FACING_LEFT:
      mvwprintw(mapWindow, player->yCoordinate, player->xCoordinate - 1, "%c", 'o');
      mvwprintw(mapWindow, player->yCoordinate, player->xCoordinate - 2, "%c", 'o');
      break;
    case FACING_UP:
      mvwprintw(mapWindow, player->yCoordinate - 1, player->xCoordinate, "%c", 'o');
      mvwprintw(mapWindow, player->yCoordinate - 2, player->xCoordinate, "%c", 'o');
      break;
    case FACING_RIGHT:
      mvwprintw(mapWindow, player->yCoordinate, player->xCoordinate + 1, "%c", 'o');
      mvwprintw(mapWindow, player->yCoordinate, player->xCoordinate + 2, "%c", 'o');
      break;
    case FACING_DOWN:
      mvwprintw(mapWindow, player->yCoordinate + 1, player->xCoordinate, "%c", 'o');
      mvwprintw(mapWindow, player->yCoordinate + 2, player->xCoordinate, "%c", 'o');
      break;
    default:
      mvwprintw(mapWindow, 0, 0, "Firing problem. Please fix me :(");
  }
  wrefresh(mapWindow);

}


/*
 *
 *
 */
void outputToScreen(){


}
