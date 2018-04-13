#!/bin/sh
#SBATCH --time=00:15:00

programs = ("serial" "parallel" "gpu")
tests=`ls $SLURM_SUBMIT_DIR/tests/*`
#SBATCH -job-name=course_project
#SBATCH --output=output/$0_$1.out
#SBATCH --time=1:00:00
#SBATCH --error=output/$0_$1.error
#SBATCH -ntasks=8

for program in "${programs[@]}"
do
	nodes=0
	for test in "${tests[@]}"
	do
		srun -N=$nodes -n1 --exclusive $program $test "${program}_${test}.bmp"
	done
done


