

add_library(arr_global_mtx lockedMsgGlobalMutexImpl.c)
add_library(arr_multi_mtx lockedMsgMultiMutexImpl.c)
add_library(arr_global_rwlock lockedMsgGlobalRWLockImpl.c)
add_library(arr_multi_rwlock lockedMsgMultiRWLockImpl.c)

add_executable(main main.c common.c)
target_link_libraries(main arr_global_mtx pthread m)

add_executable(client client.c common.c)
target_link_libraries(client pthread m)