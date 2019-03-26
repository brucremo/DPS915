//exercise 5.20 Deitel and deitel pag 242
	//file triangle.h
	//class definition
class Triangle
{
public:
	Triangle(double, double, double, int); //constructor initializing the 3 triangle dimensions
	void calculateDimensions(double, double, double, int); //assigns dimensions
	//int getTriangle( ) ; //get the value of the dimensions
	void printDimensions(double, double, double); //print dimensions
private:
	double side1;
	double side2;
	double hypotenuse;
};