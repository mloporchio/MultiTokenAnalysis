#
#	File:	makefile
#	Author:	Matteo Loporchio
#

CXX=g++
CXX_FLAGS=-O3 --std=c++11 -I /data/matteoL/igraph/include/igraph
LD_FLAGS=-L /data/matteoL/igraph/lib -ligraph -fopenmp

.PHONY: clean

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) -c $^ 

graph_degree: graph.o graph_degree.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

multigraph_degree: graph.o multigraph_degree.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

all: collapsed_graph_degree multigraph_degree

clean:
	rm -f *.o collapsed_graph_degree multigraph_degree