## EE 451 Course Project
### Parallel Ray Tracing

#### Group: James Lee, Darwin Mendyke, Ahsan Zaman


# To run MPI Program:
1. Run setup script
	`source /usr/usc/openmpi/1.8.8/setup.sh`
2. Make MPI program
	`make mpi`
3. Request n nodes from HPC (usually ~4-6 nodes is sufficient)
	For Infiniband test: `salloc -N <n> --constraint=IB sh` 
	For Myrinet test: `salloc -N <n> --constraint=myri sh`
4. Once you are given the requested resources, iteratively run program 80 times using the corresponding number of processors:
	`for number in {1..80}; 
		do 
			mpirun mpi tests/<testfile> <testfile>.bmp $number; 
		done`
### To run GPU program:
1. Run setup script 
	`source /usr/usc/cuda/default/setup.sh`
2. Make GPU program
	`make gpu`
2. Request 1 gpu core from HPC
	`salloc -gres=gpu:<number> sh`
3. Run program
	gpu <inputfile> <outputfile>


---

### Serial implementation:
#### Pseudocode:
1. Load and parse text file
2. Draw scene using raytracing algorithm
    1. For each pixel (x,y) in the screen, call a tracer function:
        1. Create an eye ray from the center of projection to that (x,y) location
	2. Check if the ray intersects with any objects in the scene
	3. For the closest intersection point P, calculate the total light contribution to that point
	    1. For each light in the scene:
	        1. Create a shadow ray from P to the light source
		2. Check if shadow ray intersects with any shapes in the scene
		3. If no shadow, calculate illumination using phong shading equation
	    2. Recursively call tracer function on the reflected eye ray to get the reflected illumination component
	    3. Sum and return the total illumination for P
3. Create bitmap image of drawing

#### Runtimes

| Test Name        | Execution Time          
| ------------- |:-------------:| 
| Spheres | 0.969888 |
| Table      | 12.51482 |
| Siggraph      | 130.153463 |

---

### Parallel implementation:
#### Pseudocode:
1. Load and parse text file
2. Draw scene using raytracing algorithm
    1. Create a thread for each (x,y) pixel. Divide threads amongst processors available and call a tracer function:
        1. Create an eye ray from the center of projection to that (x,y) location
	2. Check if the ray intersects with any objects in the scene
	3. For the closest intersection point P, calculate the total light contribution to that point
	    1. For each light in the scene:
	        1. Create a shadow ray from P to the light source
		2. Check if shadow ray intersects with any shapes in the scene
		3. If no shadow, calculate illumination using phong shading equation
	    2. Recursively call tracer function on the reflected eye ray to get the reflected illumination component
	    3. Sum and return the total illumination for P
3. Send all calculated RGB values to process 0.
3. Create bitmap image of drawing

### Runtimes
##### Spheres Test Results 
![Spheres Results](https://github.com/ahsanzam/Parallel_Raytracer/blob/master/Results/spheres_mpi_results.png)
##### Table Test Results 
![Table Results](https://github.com/ahsanzam/Parallel_Raytracer/blob/master/Results/tables_mpi_results.png)
##### Siggraph Test Results 
![Siggraph Results](https://github.com/ahsanzam/Parallel_Raytracer/blob/master/Results/siggraph_mpi_results.png)

---

### GPU implementation:
#### Pseudocode:


### Runtimes:

| Test Name        | Execution Time          
| ------------- |:-------------:| 
| Siggraph      | ? | 
| Table      | ?      |  
| Spheres | ?      |  
| Simple 1 | ?      |  
| Simple 2 | ?      |  

