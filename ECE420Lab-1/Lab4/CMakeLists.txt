add_executable(datatrim datatrim.c)

add_library(lab4io Lab4_IO.c Lab4_IO.h)

add_executable(serialtester serialtester.c Lab4_IO.h)
target_link_libraries(serialtester lab4io)
target_link_libraries(serialtester m)

find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

add_executable(main main.c)
target_link_libraries(main lab4io)
target_link_libraries(main ${MPI_C_LIBRARIES})
target_link_libraries(main m)
