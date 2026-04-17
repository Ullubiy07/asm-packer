all: macro.o main.o
	gcc -static -g main.o macro.o -o main -m32 -no-pie -Wl,--no-warn-execstack

main.o: main.asm
	nasm -f elf32 -o main.o main.asm

macro.o: macro.c
	gcc -g -c macro.c -o macro.o -m32 -no-pie -Wl,--no-warn-execstack

clean:
	rm *.o