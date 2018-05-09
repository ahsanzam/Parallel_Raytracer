EE 451 Course Project: Parallel Ray Tracing

Authors: James Lee, Darwin Mendyke, Ahsan Zaman

---

To run serial on local PC :
1.	Make serial program: `make serial`
2.	Type `./serial tests/<test> test_output.bmp`
	Output will in in `test_output.bmp`. 

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
	On Infiniband: `sh test_mpi.sh tests/tables.txt Infiniband`
	On Myrinet: `sh test_mpi.sh Myrinet`
5. To see results, open the `Results` folder and check the text files that were generated. 

The Results folder is prefilled with runtime results we obtained from our runs of USC's HPC systems. Image outputs can be found at project root. If desired, you can generate graphs of the results one by one in html format once you have finished running the testing script on both Infiniband and Myrinet. To do so, open the included `makeGraph.py` Python program and uncomment the command to make the graph you wish to see. The result can then be found in the projcet root with the filename `temp-plot.html`.   
Note that you will need to install Plotly (run `pip install plotly`) and uncomment one line from 40 to 46 to generate the desired graph. 

---

To run GPU program on HPC:
1. Run setup script 
	`source /usr/usc/cuda/default/setup.sh`
2. Make GPU program
	`make gpu`
2. Request 1 gpu core from HPC
	`salloc --gres=gpu:1 sh` 
3. Run program
	srun gpu <inputfile> <outputfile>
	(inputfile is any )
Program will run iteratively using from 1x1 to 16x16 blocks and display the corresponding output.