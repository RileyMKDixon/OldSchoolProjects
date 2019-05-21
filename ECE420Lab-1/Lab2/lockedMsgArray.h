#pragma once

typedef struct msg_arr {
  void *msg_arr_impl;
} msg_arr_t;

msg_arr_t initLockedMsgArr(int num_msgs);
void freeLockedMsgArr(msg_arr_t *msg_arr);
void setContentLocked(char* src, int pos, msg_arr_t *msg_arr);
void getContentLocked(char* dst, int pos, msg_arr_t *msg_arr);