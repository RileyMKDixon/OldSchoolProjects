cmake_minimum_required(VERSION 2.8.3)

add_executable(matrixgen matrixgen.c)

add_library(lab1_IO lab1_IO.c)

add_executable(serialtester serialtester.c)
target_link_libraries(serialtester lab1_IO)

add_executable(lab1 main.c)
target_link_libraries(lab1 lab1_IO m pthread)
