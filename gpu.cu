/*
EE 451
Course Project: Raytracer
Serial Version

Names: James Lee, Darwin Mendyke, Ahsan Zaman
*/

#include <stdlib.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <vector>
#include <string.h>
#include <time.h>

using namespace std;

#define MAX_TRIANGLES 2000
#define MAX_SPHERES 10
#define MAX_LIGHTS 10

char *filename=0;

//bool done = false;

//you may want to make these smaller for debugging purposes
#define WIDTH 640
#define HEIGHT 480

//the field of view of the camera
#define fov 60.0

unsigned char buffer[HEIGHT][WIDTH][3];

struct Vertex
{
  double position[3];
  double color_diffuse[3];
  double color_specular[3];
  double normal[3];
  double shininess;
};

typedef struct _Triangle
{
  struct Vertex v[3];
} Triangle;

typedef struct _Sphere
{
  double position[3];
  double color_diffuse[3];
  double color_specular[3];
  double shininess;
  double radius;
} Sphere;

typedef struct _Light
{
  double position[3];
  double color[3];
} Light;

__device__ Triangle* triangles;//[MAX_TRIANGLES];
__device__ Sphere* spheres;//[MAX_SPHERES];
__device__ Light* lights;//[MAX_LIGHTS];
__device__ double* ambient_light;//[3];

__device__ int* num_triangles;//=0;
__device__ int* num_spheres;//=0;
__device__ int* num_lights;//=0;

// Helper function to normalize a given vecter to a certain length, typically 1
__device__
void normalize(double p[3])
{
   double distance = fmax(sqrt(pow(p[0], 2.0) + pow(p[1], 2.0) + pow(p[2], 2.0)), 0.001);
   p[0] = p[0] / distance;
   p[1] = p[1] / distance;
   p[2] = p[2] / distance;
}

// Vector arithmitec function to perform vector subtraction
__device__
void subtract(double v0[3], double v1[3], double result[3])
{
   for (int i = 0; i < 3; i++) result[i] = v0[i] - v1[i];
}

// Vector arithmitec function to perform vector multiplication
__device__
void multiply(double v[3], double s, double result[3])
{
   for (int i = 0; i < 3; i++) result[i] = v[i] * s;
}

// Vector arithmitec function to calculate the vector cross product
__device__
void cross(double v0[3], double v1[3], double result[3])
{
   result[0] = (v0[1] * v1[2]) - (v1[1] * v0[2]);
   result[1] = (v1[0] * v0[2]) - (v0[0] * v1[2]);
   result[2] = (v0[0] * v1[1]) - (v1[0] * v0[1]);
}

// Vector arithmitec function to calculate the vector dot product
__device__
double dot(double v0[3], double v1[3])
{
   return (v0[0] * v1[0]) + (v0[1] * v1[1]) + (v0[2] * v1[2]);
}

// Helper function to compare distances between two points relative to the origin.
// Sets inter with the closer point
__device__
bool compDistances(double o[3], double (&inter)[3], double (&newInter)[3])
{
   double a[3] = {inter[0] - o[0], inter[1] - o[1], inter[2] - o[2]};
   double b[3] = {newInter[0] - o[0], newInter[1] - o[1], newInter[2] - o[2]};
   if (fmax(sqrt(pow(b[0], 2.0) + pow(b[1], 2.0) + pow(b[2], 2.0)), 0.001) < fmax(sqrt(pow(a[0], 2.0) + pow(a[1], 2.0) + pow(a[2], 2.0)), 0.001))
   {
      for (int i = 0; i < 3; i++) inter[i] = newInter[i];
      return true;
   }
   return false;
}

// Given a sphere and a ray, determines if there is an intersection.
// If so, stores the coords of the intersection
__device__
bool intersectsSphere(Sphere sphere, double o[3], double d[3], double (&intersection)[3])
{
   double a = 1.0;
   double b = 2 * (d[0] * (o[0] - sphere.position[0]) + d[1] * (o[1] - sphere.position[1]) + d[2] * (o[2] - sphere.position[2]));
   double c = pow((o[0] - sphere.position[0]), 2.0) + pow((o[1] - sphere.position[1]), 2.0) + pow((o[2] - sphere.position[2]), 2.0) - pow(sphere.radius, 2.0);
   double t0 = (-b + sqrt(pow(b, 2.0) - (4.0 * a * c))) / 2.0;
   double t1 = (-b - sqrt(pow(b, 2.0) - (4.0 * a * c))) / 2.0;
   if (fmin(t0, t1) > 0)
   {
      double newIntersection[3] = {o[0] + fmin(t0, t1) * d[0], o[1] + fmin(t0, t1) * d[1], o[2] + fmin(t0, t1) * d[2]};

      if (compDistances(o, intersection, newIntersection)) return true;
   }
   return false;
}

// Given a triangle shape and a ray, determines if there is an intersection, using examples from the above link
__device__
bool intersectsTriangle(Triangle triangle, double o[3], double d[3], double (&intersection)[3], double (&bcoords)[3])
{
   double v0v1[3], v0v2[3], pvec[3], tvec[3], qvec[3], t, u, v;
   subtract(triangle.v[1].position, triangle.v[0].position, v0v1);
   subtract(triangle.v[2].position, triangle.v[0].position, v0v2);

   cross(d, v0v2, pvec);
   double det = dot(v0v1, pvec);

   double invDet = 1 / det;

   subtract(o, triangle.v[0].position, tvec);
   u = dot(tvec, pvec) * invDet;
   if (u < 0 || u > 1) return false;

   cross(tvec, v0v1, qvec);
   v = dot(d, qvec) * invDet;
   if (v < 0 || u + v > 1) return false;

   t = dot(v0v2, qvec) * invDet;
   if (t <= 0) return false; // checks if intersection is in positive ray direction or negative

   double newIntersection[3] = {o[0] + t * d[0], o[1] + t * d[1], o[2] + t * d[2]};
   if (compDistances(o, intersection, newIntersection))
   {
      bcoords[0] = u;
      bcoords[1] = v;
      bcoords[2] = 1.0 - bcoords[0] - bcoords[1];
      return true;
   }

   return false;
}


// Recursive function to perform ray tracing given a ray.
__device__
void trace(double o[3], double d[3], int num, double* trace_result){
   bool intersectTriangle = false, intersectSphere = false;
   double bcoords[3], other1[3], intersection[3] = {1000.0, 1000.0, 1000.0};
   int index = 0;

   // looks for an intersection between the input ray and a shape
   for (int i = 0; i < *num_triangles; i++) if (intersectsTriangle(triangles[i], o, d, intersection, bcoords)) intersectTriangle = true, index = i;
   for (int i = 0; i < *num_spheres; i++) if (intersectsSphere(spheres[i], o, d, intersection)) intersectSphere = true, index = i;

   // returns background color if no intersections or if reach max recursive call
   if ((!intersectTriangle && !intersectSphere) || num > 2){
    trace_result[0] = 1.0;
    trace_result[1] = 1.0;
    trace_result[2] = 1.0;
   }

   double illumination[3] = {ambient_light[0], ambient_light[1], ambient_light[2]};
   double l[3], n[3], n1[3], v[3], r[3], recursive_r[3], diffuse[3], specular[3], shiny;

   // iterates through each light in the scene
   for (int j = 0; j < *num_lights; j++)
   {
      for (int i = 0; i < 3; i++)
      {
         l[i] = lights[j].position[i] - intersection[i];
         v[i] = o[i] - intersection[i];
      }
      if (intersectSphere)
      {
         for (int i = 0; i < 3; i++)
         {
            n[i] = intersection[i] - spheres[index].position[i];
            diffuse[i] = spheres[index].color_diffuse[i];
            specular[i] = spheres[index].color_specular[i];
         }
         shiny = spheres[index].shininess;
      }
      else if (intersectTriangle)
      {
         Triangle shape = triangles[index];
         for (int i = 0; i < 3; i++)
         {
            n[i] = shape.v[0].normal[i] * bcoords[2] + shape.v[1].normal[i] * bcoords[0] + shape.v[2].normal[i] * bcoords[1];
            diffuse[i] = shape.v[0].color_diffuse[i] * bcoords[2] + shape.v[1].color_diffuse[i] * bcoords[0] + shape.v[2].color_diffuse[i] * bcoords[1];
            specular[i] = shape.v[0].color_specular[i] * bcoords[2] + shape.v[1].color_specular[i] * bcoords[0] + shape.v[2].color_specular[i] * bcoords[1];
         }
         shiny = shape.v[0].shininess * bcoords[2] + shape.v[1].shininess * bcoords[0] + shape.v[2].shininess * bcoords[1];
      }

      // initializes the shadow ray from the intersection point
      double normalized_pos[3] = {lights[j].position[0] - intersection[0], lights[j].position[1] - intersection[1], lights[j].position[2] - intersection[2]};
      double shadowIntersection[3] = {lights[j].position[0], lights[j].position[1], lights[j].position[2]};
      double shadowOrigin[3] = {intersection[0] + 0.001 * n[0], intersection[1] + 0.001 * n[1], intersection[2] + 0.001 * n[2]};
      bool shadow = false;
      normalize(normalized_pos);

      // checks if the shadow ray intersects with a shape
      for (int i = 0; i < *num_spheres; i++)
         if (intersectsSphere(spheres[i], shadowOrigin, normalized_pos, shadowIntersection)) shadow = true;
      for (int i = 0; i < *num_triangles; i++)
         if (intersectsTriangle(triangles[i], shadowOrigin, normalized_pos, shadowIntersection, other1)) shadow = true;

      normalize(l);
      normalize(n);
      normalize(v);
      multiply(n, 2 * dot(l, n), n1);
      subtract(n1, l, r);
      normalize(r); // calculates the reflection ray

      // if there is no shadow at the point, calculates illumination using phong shading equation
      if (!shadow)
      {
         for (int i = 0; i < 3; i++)
         {
            double a = diffuse[i] * fmax(0.0, dot(l, n));
            double b = specular[i] * pow(fmax(0.0, dot(v, r)), shiny);
            illumination[i] += lights[j].color[i] * (a + b);
            illumination[i] = fmin(illumination[i], 1.0);
         }
      }
   }
   // return illumination;
   // uncomment this code below to recursively call tracer function on reflection ray
   multiply(n, 2 * dot(v, n), n1);
   subtract(n1, v, recursive_r);
   double recursiveOrigin[3] = {intersection[0] + 0.01 * recursive_r[0], intersection[1] + 0.01 * recursive_r[1], intersection[2] + 0.01 * recursive_r[2]};
   normalize(recursive_r);
   trace(recursiveOrigin, recursive_r, ++num, trace_result);
   for (int i = 0; i < 3; i++)
   {
      trace_result[i] = (1 - specular[i]) * illumination[i] + specular[i] * trace_result[i];
   }
}

// Iterates through each pixel on the window and generates a ray, which it passes to the tracer function
__global__
void draw_scene(double* result)
{
  double focalLength = 0.5 * WIDTH * sqrt(3.0) * 0.75;
  double origin[3] = {0, 0, 0};
  int x = threadIdx.x + blockIdx.x * blockDim.x;
  int y = threadIdx.y + blockIdx.y * blockDim.y;
  double direction[3] = {x - ((double) WIDTH / 2.0), y - ((double) HEIGHT / 2.0), -1 * focalLength};
  normalize(direction);
  double* color = new double[3];
  trace(origin, direction, 0, color);
  result[1]=255*1;//color[0];
  result[2]=255*1;//color[1];
  result[3]=255*1;//color[2];
}

void parse_check(char *expected,char *found)
{
  if(strcasecmp(expected,found))
    {
      // char error[100];
      printf("Expected '%s ' found '%s '\n",expected,found);
      printf("Parse error, abnormal abortion\n");
      exit(0);
    }

}

void parse_doubles(FILE*file, char *check, double p[3])
{
  char str[100];
  fscanf(file,"%s",str);
  parse_check(check,str);
  fscanf(file,"%lf %lf %lf",&p[0],&p[1],&p[2]);
  // printf("%s %lf %lf %lf\n",check,p[0],p[1],p[2]);
}

void parse_rad(FILE*file,double *r)
{
  char str[100];
  fscanf(file,"%s",str);
  parse_check((char *)"rad:",str);
  fscanf(file,"%lf",r);
  // printf("rad: %f\n",*r);
}

void parse_shi(FILE*file,double *shi)
{
  char s[100];
  fscanf(file,"%s",s);
  parse_check((char *)"shi:",s);
  fscanf(file,"%lf",shi);
  // printf("shi: %f\n",*shi);
}

int loadScene(char *argv, int num_triangles_, int num_spheres_, int num_lights_, Triangle* triangles_, Sphere* spheres_, Light* lights_, double* ambient_light_)
{
  FILE *file = fopen(argv,"r");
  int number_of_objects;
  char type[50];
  int i;
  Triangle t;
  Sphere s;
  Light l;
  fscanf(file,"%i",&number_of_objects);

  // printf("number of objects: %i\n",number_of_objects);
  // char str[200];

  parse_doubles(file,(char *)"amb:",ambient_light_);

  for(i=0;i < number_of_objects;i++)
  {
    fscanf(file,"%s\n",type);
    // printf("%s\n",type);
    if(strcasecmp(type,"triangle")==0)
    {
      // printf("found triangle\n");
      int j;
      for(j=0;j < 3;j++)
      {
        parse_doubles(file,(char *)"pos:",t.v[j].position);
        parse_doubles(file,(char *)"nor:",t.v[j].normal);
        parse_doubles(file,(char *)"dif:",t.v[j].color_diffuse);
        parse_doubles(file,(char *)"spe:",t.v[j].color_specular);
        parse_shi(file,&t.v[j].shininess);
      }
      if(num_triangles_ == MAX_TRIANGLES)
      {
        printf("too many triangles, you should increase MAX_TRIANGLES!\n");
        exit(0);
      }
      triangles_[num_triangles_++] = t;
    }
    else if(strcasecmp(type,"sphere")==0)
    {
      // printf("found sphere\n");
      parse_doubles(file,(char *)"pos:",s.position);
      parse_rad(file,&s.radius);
      parse_doubles(file,(char *)"dif:",s.color_diffuse);
      parse_doubles(file,(char *)"spe:",s.color_specular);
      parse_shi(file,&s.shininess);
      if(num_spheres_ == MAX_SPHERES) {
        printf("too many spheres, you should increase MAX_SPHERES!\n");
        exit(0);
      }
      spheres_[num_spheres_++] = s;
    }
    else if(strcasecmp(type,"light")==0)
    {
      // printf("found light\n");
      parse_doubles(file,(char *)"pos:",l.position);
      parse_doubles(file,(char *)"col:",l.color);
      if(num_lights_ == MAX_LIGHTS){
        printf("too many lights, you should increase MAX_LIGHTS!\n");
        exit(0);
      }
      lights_[num_lights_++] = l;
    }
    else{
      printf("unknown type in scene description:\n%s\n",type);
      exit(0);
    }
  }
  fclose(file);
  return 0;
}
void make_bitmap(double* rgbVals, char* fileToWrite)
{
  typedef struct                       /**** BMP file header structure ****/
      {
      unsigned int   bfSize;           /* Size of file */
      unsigned short bfReserved1;      /* Reserved */
      unsigned short bfReserved2;      /* ... */
      unsigned int   bfOffBits;        /* Offset to bitmap data */
      } BITMAPFILEHEADER;

  typedef struct                       /**** BMP file info structure ****/
      {
      unsigned int   biSize;           /* Size of info header */
      int            biWidth;          /* Width of image */
      int            biHeight;         /* Height of image */
      unsigned short biPlanes;         /* Number of color planes */
      unsigned short biBitCount;       /* Number of bits per pixel */
      unsigned int   biCompression;    /* Type of compression to use */
      unsigned int   biSizeImage;      /* Size of image data */
      int            biXPelsPerMeter;  /* X pixels per meter */
      int            biYPelsPerMeter;  /* Y pixels per meter */
      unsigned int   biClrUsed;        /* Number of colors used */
      unsigned int   biClrImportant;   /* Number of important colors */
      } BITMAPINFOHEADER;

  BITMAPFILEHEADER bfh;
  BITMAPINFOHEADER bih;

  /* Magic number for file. It does not fit in the header structure due to alignment requirements, so put it outside */
  unsigned short bfType=0x4d42;
  bfh.bfReserved1 = 0;
  bfh.bfReserved2 = 0;
  bfh.bfSize = 2+sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)+640*480*3;
  bfh.bfOffBits = 0x36;

  bih.biSize = sizeof(BITMAPINFOHEADER);
  bih.biWidth = WIDTH;
  bih.biHeight = HEIGHT;
  bih.biPlanes = 1;
  bih.biBitCount = 24;
  bih.biCompression = 0;
  bih.biSizeImage = 0;
  bih.biXPelsPerMeter = 5000;
  bih.biYPelsPerMeter = 5000;
  bih.biClrUsed = 0;
  bih.biClrImportant = 0;

  FILE *file = fopen(fileToWrite, "wb");
  if (!file)
      {
      printf("Could not write file\n");
      return;
      }

  /*Write headers*/
  fwrite(&bfType,1,sizeof(bfType),file);
  fwrite(&bfh, 1, sizeof(bfh), file);
  fwrite(&bih, 1, sizeof(bih), file);

  /*Write bitmap*/
  for (int y=0; y<bih.biHeight; y++)
      {
      for (int x = 0; x < bih.biWidth; x++)
          {
          /*compute some pixel values*/
          unsigned char r = rgbVals[x*y*1];
          unsigned char g = rgbVals[x*y*2];
          unsigned char b = rgbVals[x*y*3];
          fwrite(&b, 1, 1, file);
          fwrite(&g, 1, 1, file);
          fwrite(&r, 1, 1, file);
          }
      }
  fclose(file);   
}

inline bool exists_file(char* name){
  if(FILE *file = fopen(name, "r")){
      fclose(file);
      return true;
  }
  else return false;
}

int main (int argc, char ** argv)
{
  if (argc<3 || argc > 3){
    printf ("usage: %s <scenefile> <bmp_name>\n", argv[0]);
    exit(0);
  }
  char* fileToRead = argv[1];
  char* fileToWrite = argv[2];

  if(!exists_file(fileToRead)){
    cout << "Input file does not exist.\n" << endl;
    exit(0);
  }
  int num_triangles_=0;
  int num_spheres_=0;
  int num_lights_=0;
  Triangle triangles_[MAX_TRIANGLES];
  Sphere spheres_[MAX_SPHERES];
  Light lights_[MAX_LIGHTS];
  double ambient_light_[3];
  loadScene(fileToRead, num_triangles_, num_spheres_, num_lights_, triangles_, spheres_, lights_, ambient_light_);

  double* drawing;
  double time;
  struct timespec start, stop;
  int GRID_DIM = WIDTH;
  int BLOCK_DIM = HEIGHT;
  if( clock_gettime(CLOCK_REALTIME, &start) == -1) { perror("clock gettime");}
  
  //copy stuff over
  cudaMallocManaged(&drawing, WIDTH*HEIGHT*3*sizeof(double));

  cudaMemcpy(triangles, triangles_, MAX_TRIANGLES*sizeof( Triangle), cudaMemcpyHostToDevice);
  cudaMemcpy(spheres, spheres_, MAX_SPHERES*sizeof( Sphere), cudaMemcpyHostToDevice);
  cudaMemcpy(lights, lights_, MAX_LIGHTS*sizeof( Light), cudaMemcpyHostToDevice);
  cudaMemcpy(ambient_light, ambient_light_, 3*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(num_triangles, &num_triangles_, 1*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(num_spheres, &num_spheres_, 1*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(num_lights, &num_lights_, 1*sizeof(int), cudaMemcpyHostToDevice);

  // local_drawing = new double[WIDTH*HEIGHT*3];
  //measure how long it takes to render the image
  // cudaMemcpy(drawing, local_drawing, WIDTH*HEIGHT*sizeof(double), cudaMemcpyDeviceToHost);
  draw_scene<<<GRID_DIM, BLOCK_DIM>>>(drawing);
  cudaDeviceSynchronize();
  cout << drawing[1] << drawing[2] << drawing[2] << endl;
  // cudaMemcpy(drawing, local_drawing, WIDTH*HEIGHT*sizeof(double), cudaMemcpyDeviceToHost);
  if( clock_gettime( CLOCK_REALTIME, &stop) == -1 ) { perror("clock gettime");}
  time = (stop.tv_sec - start.tv_sec)+ (double)(stop.tv_nsec - start.tv_nsec)/1e9;
  printf("Execution time for %s: %f seconds.\n",fileToRead, time);

  make_bitmap(drawing, fileToWrite);
  
  cudaFree(drawing);
  cudaFree(triangles);
  cudaFree(spheres);
  cudaFree(lights);
  cudaFree(ambient_light);
  cudaFree(num_triangles);
  cudaFree(num_spheres);
  cudaFree(num_lights);
}
