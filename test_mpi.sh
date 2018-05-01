
tests=(spheres table siggraph)

for test in ${tests[@]};
	do
	echo Results for MPI Parallel $test.txt on $1 > Results/$test_MPI_$1.txt;
	for number in {1..80};
		do
			mpirun mpi tests/$test.txt $test_MPI_$1.bmp $number >> Results/$test_MPI_$1.txt;
		done;
	echo Completed running test $test. Output is in Results/$test_MPI_$1.txt.
	done