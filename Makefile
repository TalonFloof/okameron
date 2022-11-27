build:
	g++ -std=c++11 -Wall -Isrc/vos/headers -Isrc/utils src/vos/*.cpp src/vos/targets/*.cpp -o vos