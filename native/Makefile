
.DEFAULT: benchmark

benchmark : main.c
	gcc -Wall -Werror -O2 -o benchmark main.c -lsqlite3

run : benchmark
	./benchmark
