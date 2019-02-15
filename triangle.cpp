//exercise 5.20 Deitel and deitel pag 242
//file: triangle.cpp
//member function definition
#include "triangle.h"
#include <iostream>
using namespace std;
#include <cmath> //for the power function
// constants in the program
const int EXPONENT = 2;
const char N = '\n';
/*the constructors initialize the values of the sides to 1 and pass them to the
calculateDimensions functions */
Triangle::Triangle (double Side1, double Side2, double Hypot, int hypotMaxSize)
{
	calculateDimensions (Side1, Side2, Hypot, hypotMaxSize);
}
//set the 3 dimensions and calculates the Pythagorean triple
void Triangle::calculateDimensions (double Side1, double Side2, double Hypot, int hypotMaxSize)
{
	side1 = Side1;
	side2 = Side2;
	hypotenuse = Hypot;
	//int i = 0 ; //for the iteration in the for loop
	for (int i = 1; i <= hypotMaxSize; i++)
	{
		side1 = i;
		for (int j = 1; j <= hypotMaxSize; j++)
		{
			side2 = j;
			for (int k = 1; k <= hypotMaxSize; k++)
			{
				hypotenuse = k;
				if ((pow (side1, EXPONENT)) + (pow (side2, EXPONENT)) == (pow (hypotenuse, EXPONENT)))
				{
					printDimensions (side1, side2, hypotenuse);
				}
			}
		}
	}
}
void Triangle::printDimensions (double side1, double side2, double hypotenuse)
{
	cout << "( " << side1 << " , " << side2 << " , " << hypotenuse << " ) " << endl;
}