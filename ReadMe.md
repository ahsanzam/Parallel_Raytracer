## EE 451 Course Project
### Parallel Ray Tracing

#### Group: James Lee, Darwin Mendyke, Ahsan Zaman

---

### Serial implementation:
#### Pseudocode:
1. Load and parse text file. 
2. Draw scene using raytracing algorithm
    1. For each pixel, call tracer function:
        1. Look for an intersection between the input ray and other shapes in the drawing.
        2. If there are no intersections or if max recursive call is reached, return background color. Else:
            1. For each light in the scene:
                1. Check intersection with any object in the scene
                2. Initialize shadow ray from intersection point
                3. Check if shadow ray intersects with any shapes
                4. If no shadow, calculate illumination using phong shading equation
	    2. Recursively call tracer function on reflection ray
	    3. Sum and return total illumination for the point
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
1. Load and parse text file. 
2. Draw scene using raytracing algorithm
    1. For each pixel, create a thread. Divide threads among processors available and call tracer function:
        1. Look for an intersection between the input ray and other shapes in the drawing.
        2. If there are no intersections or if max recursive call is reached, return background color. Else:
            1. For each light in the scene:
                1. Check intersection with any object in the scene
                2. Initialize shadow ray from intersection point
                3. Check if shadow ray intersects with any shapes
                4. If no shadow, calculate illumination using phong shading equation
	    2. Recursively call tracer function on reflection ray
	    3. Sum and return total illumination for the point
3. Send all calculated RGB values to process 0.
4. Create a bitmap image of the drawing.

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

