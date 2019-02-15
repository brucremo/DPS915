g++ -pg -g -O2 -std=c++11 main.cpp triangle.cpp -o triples
triples 1 1 2 1500
gprof -p -b triples > prof.txt
cat prof.txt

