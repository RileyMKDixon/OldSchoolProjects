all:  main.c client.c common.c common.h lockedMsgGlobalMutexImpl.c lockedMsgGlobalRWLockImpl.c lockedMsgMultiMutexImpl.c lockedMsgMultiRWLockImpl.c lockedMsgArray.h
	gcc main.c lockedMsgGlobalMutexImpl.c common.c -o main1 -lm -lpthread -g -std=gnu99
	gcc main.c lockedMsgMultiMutexImpl.c common.c -o main2 -lm -lpthread -g -std=gnu99
	gcc main.c lockedMsgGlobalRWLockImpl.c common.c -o main3 -lm -lpthread -g -std=gnu99
	gcc main.c lockedMsgMultiRWLockImpl.c common.c -o main -lm -lpthread -g -std=gnu99
	gcc client.c -o client -lm -lpthread -g -std=gnu99
	gcc attacker.c -o attacker -lm -lpthread -g -std=gnu99

clean:
	rm ./main
	rm ./main1
	rm ./main2
	rm ./main3
	rm ./client
	rm ./attacker