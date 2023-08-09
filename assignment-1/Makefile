.c.o:
		gcc -c $*.c
hello:	main.o dumb.o
		gcc -o hello main.o dumb.o
main.o:	main.c dumb.h
dumb.o:	dumb.c	dumb.h
