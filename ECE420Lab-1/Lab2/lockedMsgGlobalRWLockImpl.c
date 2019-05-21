
#include "common.h"
#include "lockedMsgArray.h"
#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>

typedef struct global_rwlock_impl {
    pthread_rwlock_t rwlock;
    int num_msgs;
    char **theArray;
} global_rwlock_impl_t;


msg_arr_t initLockedMsgArr(int num_msgs) {
  global_rwlock_impl_t *impl = (global_rwlock_impl_t*)malloc(sizeof(global_rwlock_impl_t));
  impl->num_msgs = num_msgs;

  initMsgArr(num_msgs, &impl->theArray);
  pthread_rwlock_init(&impl->rwlock, NULL);

  msg_arr_t out = {impl};
  return out;
}

void freeLockedMsgArr(msg_arr_t *msg_arr) {
  global_rwlock_impl_t *impl = (global_rwlock_impl_t*)msg_arr->msg_arr_impl;
  freeMsgArr(impl->num_msgs, impl->theArray);
  pthread_rwlock_destroy(&impl->rwlock);
  free(impl);
}

void setContentLocked(char* src, int pos, msg_arr_t *msg_arr) {
  global_rwlock_impl_t *impl = (global_rwlock_impl_t*)msg_arr->msg_arr_impl;
  pthread_rwlock_wrlock(&impl->rwlock);
  setContent(src, pos, impl->theArray);
  pthread_rwlock_unlock(&impl->rwlock);
}

void getContentLocked(char* dst, int pos, msg_arr_t *msg_arr) {
  global_rwlock_impl_t *impl = (global_rwlock_impl_t*)msg_arr->msg_arr_impl;
  pthread_rwlock_rdlock(&impl->rwlock);
  getContent(dst, pos, impl->theArray);
  pthread_rwlock_unlock(&impl->rwlock);
}