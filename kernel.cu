//exercise 5.20 Deitel and deitel pag 242
//file: triangle_main.cpp
//file containing main function
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
#include <time.h>
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
//const int ntpb = 1024;

__global__ void valueCheck(float value, float * arr, float * check, const int size) {
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int t = threadIdx.x;
	__shared__ float s_check[ntpb];
	__shared__ float s_arr[ntpb];
	
	s_check[t] = check[idx];
	s_arr[t] = arr[idx];
	__syncthreads();

	if (idx < size) {

		for (int i = 0; i < size; i++) {

			if ((value * value) + (s_arr[i] * s_arr[i]) == (s_check[t] * s_check[t]) {

				printf("Triple: ( %f  %f  %f )\n", value, s_arr[i], s_check[t]);
			}
		}

		__syncthreads();
	}
}

void printDimensions(float side1, float side2, float hypotenuse) {

	cout << "Triple: ( " << side1 << " , " << side2 << " , " << hypotenuse << " ) " << endl;
}

float gen() {

	static float i = 0;
	return ++i;
}

//set the 3 dimensions and calculates the Pythagorean triple
void calculateCUDA(float Side1, float Side2, float Hypot, int hypotMaxSize) {

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

	// launch
	int nb = (hypotMaxSize + ntpb - 1) / ntpb;


	for (int i = 0; i < hypotMaxSize; i++) {

		valueCheck << <nb, ntpb >> > (*pos++, d_s2, d_Hyp, hypotMaxSize);
		cudaDeviceSynchronize();
	}
}

void calculateSerial(float Side1, float Side2, float Hypot, int hypotMaxSize) {

	//int i = 0 ; //for the iteration in the for loop
	for (int i = 1; i <= hypotMaxSize; i++) {

		Side1 = i;
		for (int j = 1; j <= hypotMaxSize; j++) {

			Side2 = j;
			for (int k = 1; k <= hypotMaxSize; k++) {

				Hypot = k;
				if ((Side1 * Side1) + (Side2 * Side2) == (Hypot * Hypot)) {

					printDimensions(Side1, Side2, Hypot);
				}
			}
		}
	}
}

int main(int argc, char * argv[]) {

	//Timing start
	clock_t t;
	t = clock();

	calculateCUDA(std::stof(argv[1]), std::stof(argv[2]), std::stof(argv[3]), std::stoi(argv[4])); //create Triangle object

	//Timing capture
	t = clock() - t;

	//Timing start
	clock_t b;
	b = clock();

	calculateSerial(std::stof(argv[1]), std::stof(argv[2]), std::stof(argv[3]), std::stoi(argv[4])); //create Triangle object

	cout << "time on GPU: " << t * 1.0 / CLOCKS_PER_SEC << " seconds" << endl;

	//Timing capture
	b = clock() - b;
	cout << "time on CPU: " << b * 1.0 / CLOCKS_PER_SEC << " seconds" << endl;

	return 0;
}
