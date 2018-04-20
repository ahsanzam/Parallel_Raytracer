#!/bin/sh

#SBATCH --job-name="course_project"
#SBATCH --time=1:00:00

# programs=("serial" "parallel" "gpu")
# tests=(tests/*)
# for program in "${programs[@]}"
# do
# 	nodes=1
# 	tasksPerNode=1
# 	gpu=0
# 	for test in "${tests[@]}"
# 	do
# 		srun \
# 			--nodes=$nodes \
# 			--ntasks-per-node=$tasksPerNode \
# 			--gres=gpu:$gpu \
# 			--error="${program}_${test}.error" \
# 			--output="${program}_${test}.out" \
# 			$program $test "${program}_${test}.bmp"
# 	done
# done


srun --error="parallel.error" --output="parallel.out" parallel tests/table.txt parallel_test.bmp
