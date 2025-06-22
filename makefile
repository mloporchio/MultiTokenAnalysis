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

graph_clustering: graph.o graph_clustering.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

graph_connectivity: graph.o graph_connectivity.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

graph_degree: graph.o graph_degree.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

graph_density: graph.o graph_density.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

graph_hits: graph.o graph_hits.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

graph_pagerank: graph.o graph_pagerank.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

graph_reciprocity: graph.o graph_reciprocity.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

all: graph_clustering graph_connectivity graph_degree graph_density graph_hits graph_pagerank graph_reciprocity

clean:
	rm -f *.o graph_clustering graph_connectivity graph_degree graph_density graph_hits graph_pagerank graph_reciprocity