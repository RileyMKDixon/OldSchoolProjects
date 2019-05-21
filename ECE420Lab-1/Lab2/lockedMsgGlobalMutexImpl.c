
#include "common.h"
#include "lockedMsgArray.h"
#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>

typedef struct global_mutex_impl {
    pthread_mutex_t mutex;
    int num_msgs;
    char **theArray;
} global_mutex_impl_t;


msg_arr_t initLockedMsgArr(int num_msgs) {
  global_mutex_impl_t *impl = (global_mutex_impl_t*)malloc(sizeof(global_mutex_impl_t));
  impl->num_msgs = num_msgs;

  initMsgArr(num_msgs, &impl->theArray);
  pthread_mutex_init(&impl->mutex, NULL);

  msg_arr_t out = {impl};
  return out;
}

void freeLockedMsgArr(msg_arr_t *msg_arr) {
  global_mutex_impl_t *impl = (global_mutex_impl_t*)msg_arr->msg_arr_impl;
  freeMsgArr(impl->num_msgs, impl->theArray);
  pthread_mutex_destroy(&impl->mutex);
  free(impl);
}

void setContentLocked(char* src, int pos, msg_arr_t *msg_arr) {
  global_mutex_impl_t *impl = (global_mutex_impl_t*)msg_arr->msg_arr_impl;
  pthread_mutex_lock(&impl->mutex);
  setContent(src, pos, impl->theArray);
  pthread_mutex_unlock(&impl->mutex);
}

void getContentLocked(char* dst, int pos, msg_arr_t *msg_arr) {
  global_mutex_impl_t *impl = (global_mutex_impl_t*)msg_arr->msg_arr_impl;
  pthread_mutex_lock(&impl->mutex);
  getContent(dst, pos, impl->theArray);
  pthread_mutex_unlock(&impl->mutex);
}