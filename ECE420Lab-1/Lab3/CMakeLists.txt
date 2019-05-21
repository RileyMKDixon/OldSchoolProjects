add_executable(datagen datagen.c)
target_link_libraries(datagen lab3io)

add_library(lab3io Lab3IO.c)

add_executable(serialtester serialtester.c)
target_link_libraries(serialtester lab3io m)

add_executable(main main.c)
target_link_libraries(main lab3io m)




