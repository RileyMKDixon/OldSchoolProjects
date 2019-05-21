node1IP = 192.168.0.98
node2IP = 192.168.0.182
node3IP = 192.168.0.181
node4IP = 192.168.0.175
filePath = ~/ECE420Lab-1/Lab4
mainExe = ./main
metaDataFile = ./data_input_meta
linkDataFile = ./data_input_link

all : main.c Lab4_IO.c
	mpicc main.c Lab4_IO.c -g -lm --std=gnu99 -o main
	#ssh 192.168.0.182
	scp -q $(mainExe) $(node2IP):$(filePath)
	scp -q $(linkDataFile) $(node2IP):$(filePath)
	scp -q $(metaDataFile) $(node2IP):$(filePath)
	#ssh 192.168.0.181
	scp -q $(mainExe) $(node3IP):$(filePath)
	scp -q $(linkDataFile) $(node3IP):$(filePath)
	scp -q $(metaDataFile) $(node3IP):$(filePath)
	#ssh 192.168.0.175
	scp -q $(mainExe) $(node4IP):$(filePath)
	scp -q $(linkDataFile) $(node4IP):$(filePath)
	scp -q $(metaDataFile) $(node4IP):$(filePath)
	#ssh 192.168.0.98 #Is our first node, we do not need to do anything here

run : main
	mpirun -np 4 -f hosts ./main