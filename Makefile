build:
	gcc -ansi -Wall -Isrc/vos/headers -Isrc/utils src/vos/*.c src/vos/targets/*.c -o vos