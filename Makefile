# Makefile
# EE 451
# Course Project

all: serial parallel gpu

serial:
	g++ -std=c++11 -O3 -Wno-deprecated-declarations serial.cpp -o serial

mpi:
	source /usr/usc/openmpi/1.8.8/setup.sh
	mpiCC -std=c++11 -O3 -lm parallel_mpi.cpp -o mpi

gpu:
	nvcc --std=c++11 -arch=sm_20 gpu.cu -o gpu

clean:
	-rm -rf core *.o *~ "#"*"#" serial gpu parallel
