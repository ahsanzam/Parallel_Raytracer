## EE 451 Course Project
### Parallel Ray Tracing

#### Group: James Lee, Darwin Mendyke, Ahsan Zaman

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
| Siggraph      | ? | 
| Table      | ?      |  
| Spheres | ?      |  
| Simple 1 | ?      |  
| Simple 2 | ?      |  

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

| Test Name        | Execution Time          
| ------------- |:-------------:| 
| Siggraph      | ? | 
| Table      | ?      |  
| Spheres | ?      |  
| Simple 1 | ?      |  
| Simple 2 | ?      |  


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

