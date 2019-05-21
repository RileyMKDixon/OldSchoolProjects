/*
 * This file is to clean up the code in gameserver379 and compartimentalize
 * the player actions into it's own source code file.
 *
*/

#include "player.h"

/*
 *
 *
 */
void moveLeft(struct player_t* myPlayer, int boardDimension){
  if(verifyBoundary(myPlayer->yCoordinate, myPlayer->xCoordinate - 1, boardDimension)){
    myPlayer->lastCommand = MOVING_LEFT;
    updateDirection(myPlayer, FACING_LEFT);
    myPlayer->xCoordinate--;
  }
}

/*
 *
 *
 */
void moveRight(struct player_t* myPlayer, int boardDimension){
  if(verifyBoundary(myPlayer->yCoordinate, myPlayer->xCoordinate + 1, boardDimension)){
    myPlayer->lastCommand = MOVING_RIGHT;
    updateDirection(myPlayer, FACING_RIGHT);
    myPlayer->xCoordinate++;
  }
}

/*
 *
 *
 */
void moveUp(struct player_t* myPlayer, int boardDimension){
  if(verifyBoundary(myPlayer->yCoordinate - 1, myPlayer->xCoordinate, boardDimension)){
    myPlayer->lastCommand = MOVING_UP;
    updateDirection(myPlayer, FACING_UP);
    myPlayer->yCoordinate--;
  }
}

/*
 *
 *
 */
void moveDown(struct player_t* myPlayer, int boardDimension){
  if(verifyBoundary(myPlayer->yCoordinate + 1, myPlayer->xCoordinate, boardDimension)){
    myPlayer->lastCommand = MOVING_DOWN;
    updateDirection(myPlayer, FACING_DOWN);
    myPlayer->yCoordinate++;
  }
}

/*
 *
 *
 */
void undoCommand(struct player_t* myPlayer){
  switch(myPlayer->lastCommand){
    case MOVING_LEFT:
      myPlayer->xCoordinate++;
      myPlayer->lastCommand = NONE;
      updateDirection(myPlayer, NO_DIRECTION);
      break;
    case MOVING_UP:
      myPlayer->yCoordinate--;
      myPlayer->lastCommand = NONE;
      updateDirection(myPlayer, NO_DIRECTION);
      break;
    case MOVING_RIGHT:
      myPlayer->xCoordinate--;
      myPlayer->lastCommand = NONE;
      updateDirection(myPlayer, NO_DIRECTION);
      break;
    case MOVING_DOWN:
      myPlayer->yCoordinate++;
      myPlayer->lastCommand = NONE;
      updateDirection(myPlayer, NO_DIRECTION);
      break;
    default:
      printf("Undoing an undoable command. Command ID:%d", myPlayer->lastCommand);
  }
}

/*
 *
 *
 */
int verifyBoundary(int yCoordinate, int xCoordinate, int mapDimension){
  /*if((0 <= yCoordinate && yCoordinate < mapDimension) && //y is valid
     (0 <= xCoordinate && xCoordinate < mapDimension)){  //x is valid
    return 1;
  }else{
    return 0;
  }*/
  if(yCoordinate < 0){
    return 0;
  }
  if(yCoordinate >= mapDimension){
    return 0;
  }
  if(xCoordinate < 0){
    return 0;
  }
  if(xCoordinate >= mapDimension){
    return 0;
  }
  return 1;
}

/*
 *
 *
 */
void incrementScore(struct player_t* myPlayer){
  myPlayer->score++;
}

/*
 *
 *
 */
void updateDirection(struct player_t* myPlayer, direction_t newDirection){
  if(newDirection == NO_DIRECTION){ //Revert back to old direction, use with undoCommand
    if(myPlayer->lastDirection != NO_DIRECTION){
      //If lastDirection == NO_DIRECTION do nothing
      //as we will want to keep currentDirection as the same thing.
      myPlayer->currentDirection = myPlayer->lastDirection;
      myPlayer->lastDirection = NO_DIRECTION;
    }
    //else do nothing
  }else{ //Update with new direction
    myPlayer->lastDirection = myPlayer->currentDirection;
    myPlayer->currentDirection = newDirection;
  }
}
