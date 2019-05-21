//Header file for player.c
#include <netinet/in.h> //for sockaddr_in data type
#include <stdio.h> //For printf when needed

//TODO: Put the enum INSIDE the struct
typedef enum {MOVING_LEFT = 'j', MOVING_UP = 'i', MOVING_RIGHT = 'l',
              MOVING_DOWN = 'k', FIRE = ' ', QUIT = 'x', NONE = 'X'} command_t;
//None is not null as null terminating characters are a thing.
typedef enum {FACING_LEFT = '<', FACING_UP = '^', FACING_RIGHT = '>',
              FACING_DOWN = 'v', NO_DIRECTION = 'X'} direction_t;
//NO_DIRECTION is not null for the same reasons above.

struct player_t{
  int socketFD;
  struct sockaddr_in playerSocket;

  int playerID; //Should probably try to relate with array position
  int xCoordinate;
  int yCoordinate;

  command_t lastCommand;
  direction_t currentDirection;// = FACING_UP; on init
  direction_t lastDirection;// = NO_DIRECTION; on init

  int score;

};



void moveLeft();
void moveRight();
void moveUp();
void moveDown();
void undoCommand();
int verifyBoundary();
void incrementScore();
void updateDirection();
