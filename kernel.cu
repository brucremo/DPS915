//exercise 5.20 Deitel and deitel pag 242
//file: triangle_main.cpp
//file containing main function
#include "triangle.h" //include definition of class triangle
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/device_vector.h>
#include <thrust/transform.h>
#include <thrust/functional.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/iterator/constant_iterator.h>
#include <thrust/copy.h>
#include <thrust/fill.h>
#include <thrust/sequence.h>
#include <string>
#include <iostream>
#include <algorithm>
#include <cmath> //for the power function
#include <chrono>
#include <vector> 
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#ifndef __CUDACC__
#define __CUDACC__
#endif
#include <device_functions.h>
using namespace std;
using namespace std::chrono;

// constants in the program
const int EXPONENT = 2;
const int ntpb = 1024;

__global__ void valueCheck(float value, float * arr, float * check, int size) {

	int idx = blockIdx.x * blockDim.x + threadIdx.x;

	if (idx < size) {

		for (int i = 0; i < size; i++) {

			if ( (pow(value, EXPONENT) + pow(arr[i], EXPONENT) ) == pow(check[idx], EXPONENT)) {

				printf("Triple: ( %f  %f  %f )\n", value, arr[i], check[idx]);
			}
		}

		__syncthreads();
	}
}

/*the constructors initialize the values of the sides to 1 and pass them to the
calculateDimensions functions */
Triangle::Triangle(double Side1, double Side2, double Hypot, int hypotMaxSize){

	calculateDimensions(Side1, Side2, Hypot, hypotMaxSize);
}

float gen() {

	static float i = 0;
	return ++i;
}

//set the 3 dimensions and calculates the Pythagorean triple
void Triangle::calculateDimensions(double Side1, double Side2, double Hypot, int hypotMaxSize){

	//Gathering device properties and calculating blocks and grids
	int d;
	cudaDeviceProp prop;
	cudaGetDevice(&d);
	cudaGetDeviceProperties(&prop, d);
	unsigned ntpb = prop.maxThreadsDim[0];
	unsigned ntpg = ntpb * prop.maxGridSize[0];

	if (hypotMaxSize > ntpg) {
		hypotMaxSize = ntpg;
		std::cout << "hypotMaxSize reduced to " << hypotMaxSize << std::endl;
	}

	//Arrays allocated on the device
	float * d_Hyp;
	float * d_s2;
	cudaMalloc((void**)&d_s2, hypotMaxSize * sizeof(float));
	cudaMalloc((void**)&d_Hyp, hypotMaxSize * sizeof(float));

	//Initializing host vector from 1 to hypotMaxSize
	vector<float> h_v(hypotMaxSize);
	generate(h_v.begin()++, h_v.end(), gen);

	cudaMemcpy(d_s2, h_v.data(), hypotMaxSize * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_Hyp, h_v.data(), hypotMaxSize * sizeof(float), cudaMemcpyHostToDevice);

	//Get initial data position on the vector
	float * pos = h_v.data();

	for (int i = 0; i < hypotMaxSize; i++) {

		valueCheck <<<(hypotMaxSize + ntpb - 1) / ntpb, ntpb >>> (*pos++, d_s2, d_Hyp, hypotMaxSize);
	}
}

void Triangle::printDimensions(double side1, double side2, double hypotenuse){

	cout << "( " << side1 << " , " << side2 << " , " << hypotenuse << " ) " << endl;
}

int main(int argc, char * argv[]) {

	//Timing start
	auto start = high_resolution_clock::now();

	Triangle rightTriangle(std::stof(argv[1]), std::stof(argv[2]), std::stof(argv[3]), std::stoi(argv[4])); //create Triangle object
	cudaDeviceSynchronize();

	//Timing capture
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<microseconds>(stop - start);

	// To get the value of duration use the count() 
	// member function on the duration object 
	cout << duration.count() << endl;

	return 0;
}