#!/bin/bash

tests=(spheres table siggraph)
[ -e Results ] && rm -r Results
mkdir Results
for test in ${tests[@]};
	do
	echo "Results for MPI Parallel "$test".txt on" $1 > Results/$test_MPI_$1.txt;
	for number in {1..80};
		do
			touch Results/$test_MPI_$1.txt;
			mpirun mpi tests/$test.txt $test_MPI_$1.bmp $number >> Results/$test_MPI_$1.txt;
			printf ". "
		done;
	printf "\nCompleted running test "$test". Output is in Results/"$test_MPI_$1".txt.\n"
	done