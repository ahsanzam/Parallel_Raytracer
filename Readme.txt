EE 451 Course Project: Parallel Ray Tracing

Group: James Lee, Darwin Mendyke, Ahsan Zaman

---

To run MPI Program on HPC:
1. Run setup script  
	`source /usr/usc/openmpi/1.8.8/setup.sh`
2. Make MPI program  
	`make mpi`
3. Request n nodes from HPC (usually ~4-6 nodes is sufficient)  
	For Infiniband test: `salloc -N <n> --constraint=IB sh` 
	For Myrinet test: `salloc -N <n> --constraint=myri sh`  
4. Once you are given the requested resources, iteratively run program 80 times using the corresponding number of processors:
	On Infiniband: `sh test_mpi.sh Infiniband`
	On Myrinet: `sh test_mpi.sh Myrinet`
5. To see results, open the `Results` folder and check the text files that were generated. 

If desired, you can generate graphs of the results in html format once you have finished running test on both Infiniband and Myrinet. To do so, run the included `makeGraph.py` Python program. 
Note that you will need to install Plotly (run `pip install plotly`) and uncomment one line from 40 to 46 to generate the desired graph. 

To run GPU program on HPC:
1. Run setup script 
	`source /usr/usc/cuda/default/setup.sh`
2. Make GPU program
	`make gpu`
2. Request 1 gpu core from HPC
	`salloc --gres=gpu:<number> sh`
3. Run program
	srun gpu <inputfile> <outputfile>