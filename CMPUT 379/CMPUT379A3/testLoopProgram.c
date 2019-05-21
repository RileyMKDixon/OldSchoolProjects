#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]){
  int counter = atoi(argv[1]);
  int dummy = 0;
  for(int i = 0; i < counter; i++){
    dummy++;
  }

  return 0;
}
