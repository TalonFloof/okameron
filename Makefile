build:
	gcc -std=gnu99 -fgnu89-inline -fPIC -Isrc/vos/headers -Isrc/utils src/vos/*.c src/vos/targets/*.c -o vos