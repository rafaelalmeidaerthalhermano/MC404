
main: strutils.o interface.o ias_engine.o io.o main.o ias_state.o
	gcc -g strutils.o interface.o io.o main.o ias_state.o ias_engine.o -o main

ias_engine.o: ias_engine.s
	as -g ias_engine.s -o ias_engine.o 

ias_state.o: ias_state.s
	as -g ias_state.s -o ias_state.o 

strutils.o: strutils.s
	as -g strutils.s -o strutils.o 

interface.o: interface.s
	as -g interface.s -o interface.o

io.o: io.s
	as -g io.s -o io.o

main.o: main.s
	as -g main.s -o main.o

