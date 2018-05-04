# Makefile
# EE 451
# Course Project

all: serial parallel gpu

serial:
	g++ -std=c++11 -O3 -Wno-deprecated-declarations serial.cpp -o serial

mpi:
	mpiCC -std=c++11 -O3 -lm parallel_mpi.cpp -o mpi

gpu:
	nvcc -O3 -std=c++11 -Wno-deprecated-declarations gpu.cpp -o gpu

clean:
	-rm -rf core *.o *~ "#"*"#" serial gpu parallel
