build:
	x86_64-elf-gcc -O2 -ansi -Wall -nostdlib -fPIE -c -Isrc/vos/headers -Isrc/shared/headers src/shared/*.c src/vos/*.c src/vos/targets/*.c
	ar rcs voslang.a *.o
	rm *.o
	ranlib voslang.a
	gcc -O2 -ansi -Wall -Isrc/vos/headers -Isrc/shared/headers -o vos src/cli/*.c voslang.a