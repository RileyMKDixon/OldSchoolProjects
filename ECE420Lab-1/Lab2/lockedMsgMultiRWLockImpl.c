
#include "common.h"
#include "lockedMsgArray.h"
#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>

typedef struct multi_rwlock_impl {
    pthread_rwlock_t *rwlockes;
    int num_msgs;
    char **theArray;
} multi_rwlock_impl_t;


msg_arr_t initLockedMsgArr(int num_msgs) {
  multi_rwlock_impl_t *impl = (multi_rwlock_impl_t*)malloc(sizeof(multi_rwlock_impl_t));
  impl->num_msgs = num_msgs;

  impl->rwlockes = (pthread_rwlock_t*)malloc(sizeof(pthread_rwlock_t) * num_msgs);
  initMsgArr(num_msgs, &impl->theArray);
  for(int i=0; i<impl->num_msgs; ++i) {
    pthread_rwlock_init(&impl->rwlockes[i], NULL);
  }

  msg_arr_t out = {impl};
  return out;
}

void freeLockedMsgArr(msg_arr_t *msg_arr) {
  multi_rwlock_impl_t *impl = (multi_rwlock_impl_t*)msg_arr->msg_arr_impl;
  freeMsgArr(impl->num_msgs, impl->theArray);

  for(int i=0; i<impl->num_msgs; ++i) {
    pthread_rwlock_destroy(&impl->rwlockes[i]);
  }
  free(impl->rwlockes);
  free(impl);
}

void setContentLocked(char* src, int pos, msg_arr_t *msg_arr) {
  multi_rwlock_impl_t *impl = (multi_rwlock_impl_t*)msg_arr->msg_arr_impl;
  pthread_rwlock_wrlock(&impl->rwlockes[pos]);
  setContent(src, pos, impl->theArray);
  pthread_rwlock_unlock(&impl->rwlockes[pos]);
}

void getContentLocked(char* dst, int pos, msg_arr_t *msg_arr) {
  multi_rwlock_impl_t *impl = (multi_rwlock_impl_t*)msg_arr->msg_arr_impl;
  pthread_rwlock_rdlock(&impl->rwlockes[pos]);
  getContent(dst, pos, impl->theArray);
  pthread_rwlock_unlock(&impl->rwlockes[pos]);
}