
main: strutils.o interface.o main.o ias_state.o
	gcc -g strutils.o interface.o main.o ias_state.o -o main

ias_state.o: ias_state.s
	as -g ias_state.s -o ias_state.o 

strutils.o: strutils.s
	as -g strutils.s -o strutils.o 

interface.o: interface.s
	as -g interface.s -o interface.o

main.o: main.s
	as -g main.s -o main.o

