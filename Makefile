build:
	gcc -O2 -ansi -Wall -c -Isrc/vos/headers -Isrc/utils src/vos/*.c src/vos/targets/*.c
	ar rcs voslang.a *.o
	rm *.o
	gcc -O2 -ansi -Wall -Isrc/vos/headers -Isrc/utils src/cli/*.c -o vos