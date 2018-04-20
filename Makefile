# Makefile
# EE 451
# Course Project

# change PIC_PATH if path has changed
#PIC_PATH = $(abspath $(CURDIR)/pic)

#INCLUDE = -I$(PIC_PATH)
#LIBRARIES = -L$(PIC_PATH) -framework OpenGL -framework GLUT -lpicio $(PIC_PATH)/libjpeg.a

COMPILER = g++ -std=c++11
COMPILERFLAGS = -O3 -Wno-deprecated-declarations
COMPILERFLAGS_PARALLEL = -fopenmp
COMPILERFLAGS_GPU = -O3

all: serial parallel gpu

serial:
	$(COMPILER) $(COMPILERFLAGS) serial.cpp -o serial

parallel:
	$(COMPILER) $(COMPILERFLAGS) $(COMPILERFLAGS_PARALLEL) parallel.cpp -o parallel

mpi:
	# source /usr/usc/openmpi/1.8.8/setup.sh
	mpiCC -std=c++11 -O3 -lm parallel_mpi.cpp -o mpi
	# $(COMPILER) $(COMPILERFLAGS) $(COMPILERFLAGS_PARALLEL) parallel.cpp -o parallel

gpu:
	$(COMPILER) $(COMPILERFLAGS) $(COMPILERFLAGS_GPU) gpu.cpp -o gpu

clean:
	-rm -rf core *.o *~ "#"*"#" serial gpu parallel

	# for testing:
# for number in {1..640}; do mpirun mpi tests/table.txt table_mpi.bmp $number; done