
#include "common.h"
#include "lockedMsgArray.h"
#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>

typedef struct multi_mutex_impl {
    pthread_mutex_t *mutexes;
    int num_msgs;
    char **theArray;
} multi_mutex_impl_t;


msg_arr_t initLockedMsgArr(int num_msgs) {
  multi_mutex_impl_t *impl = (multi_mutex_impl_t*)malloc(sizeof(multi_mutex_impl_t));
  impl->num_msgs = num_msgs;

  impl->mutexes = (pthread_mutex_t*)malloc(sizeof(pthread_mutex_t) * num_msgs);
  initMsgArr(num_msgs, &impl->theArray);
  for(int i=0; i<impl->num_msgs; ++i) {
    pthread_mutex_init(&impl->mutexes[i], NULL);
  }

  msg_arr_t out = {impl};
  return out;
}

void freeLockedMsgArr(msg_arr_t *msg_arr) {
  multi_mutex_impl_t *impl = (multi_mutex_impl_t*)msg_arr->msg_arr_impl;
  freeMsgArr(impl->num_msgs, impl->theArray);

  for(int i=0; i<impl->num_msgs; ++i) {
    pthread_mutex_destroy(&impl->mutexes[i]);
  }
  free(impl->mutexes);
  free(impl);
}

void setContentLocked(char* src, int pos, msg_arr_t *msg_arr) {
  multi_mutex_impl_t *impl = (multi_mutex_impl_t*)msg_arr->msg_arr_impl;
  pthread_mutex_lock(&impl->mutexes[pos]);
  setContent(src, pos, impl->theArray);
  pthread_mutex_unlock(&impl->mutexes[pos]);
}

void getContentLocked(char* dst, int pos, msg_arr_t *msg_arr) {
  multi_mutex_impl_t *impl = (multi_mutex_impl_t *) msg_arr->msg_arr_impl;
  pthread_mutex_lock(&impl->mutexes[pos]);
  getContent(dst, pos, impl->theArray);
  pthread_mutex_unlock(&impl->mutexes[pos]);
}