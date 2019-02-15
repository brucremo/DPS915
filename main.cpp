//exercise 5.20 Deitel and deitel pag 242
//file: triangle_main.cpp
//file containing main function
#include "triangle.h" //include definition of class triangle
#include <string>
int main (int argc, char * argv[]) {

	Triangle rightTriangle (std::stof(argv[1]), std::stof (argv[2]), std::stof (argv[3]), std::stoi (argv[4])); //create Triangle object

	return 0;
}