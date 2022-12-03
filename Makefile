build:
	gcc -ansi -Wall -Isrc/vos/headers -Isrc/utils src/utils/tgc.c src/vos/*.c src/vos/targets/*.c -o vos