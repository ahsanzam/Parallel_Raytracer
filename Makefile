# Makefile
# EE 451
# Course Project
# Authors: Ahsan Zaman, James Lee, Darwin Mendyke

all: clean serial mpi gpu

serial:
	g++ -std=c++11 -O3 -Wno-deprecated-declarations serial.cpp -o serial

mpi:
	mpiCC -std=c++11 -O3 -lm parallel_mpi.cpp -o mpi

gpu:
	nvcc --std=c++11 -arch=sm_20 gpu.cu -o gpu

clean:
	-rm -rf core *.o *~ "#"*"#" serial mpi gpu

source:
	source /usr/usc/cuda/default/setup.sh
	source /usr/usc/openmpi/1.8.8/setup.sh

