STDFLAGS = -std=c99 -D_GNU_SOURCE -pthread
XFCE = -H --hide-menubar
CLIENT = gameclient379
SERVER = gameserver379

all: server client

client: gameclient379.c
	gcc $(STDFLAGS) $(CLIENT).c player.c -o $(CLIENT) -l ncurses

server: gameserver379.c client
	gcc $(STDFLAGS) $(SERVER).c -o $(SERVER)

#run quickly opens up two new terminal emulators and runs both of them
#This will use arbitrary AND constant parameters for quick testing
#as the various outputs should be predictable. Testing with other
#parameters is required when initial testing passes.
run:
	xfce4-terminal -e './$(SERVER) 16 0.2 8989 1547543314' $(XFCE) --title=SERVER
	xfce4-terminal -e './$(CLIENT) 127.0.0.1 8989' $(XFCE) --title=CLIENT

clean:
	rm $(SERVER) $(CLIENT) core

#used to quickly show any processes owning the predefined run ports
#NEEDS to be removed before submission.
ports:
	netstat -ap | grep :8989

#Allows the core file to be dumped and then analyzed by gdb.
debugon:
	ulimit -c unlimited
