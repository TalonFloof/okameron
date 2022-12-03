build:
	gcc -O2 -ansi -Wall -Isrc/vos/headers -Isrc/utils src/vos/*.c src/vos/targets/*.c -o vos