#
#	File:	makefile
#	Author:	Matteo Loporchio
#

CXX=g++
CXX_FLAGS=-O3 --std=c++11 -I /data/matteoL/igraph/include/igraph
LD_FLAGS=-L /data/matteoL/igraph/lib -ligraph -fopenmp
JC=javac
JFLAGS=-cp "src:lib/*"
SRC_DIR=src
OBJ_DIR=obj
BIN_DIR=bin

# Create output directories
$(shell mkdir -p $(OBJ_DIR) $(BIN_DIR))

.PHONY: classes clean all

classes:
	$(JC) $(JFLAGS) -d $(BIN_DIR) $(SRC_DIR)/*.java

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXX_FLAGS) -c $< -o $@

$(BIN_DIR)/graph_assortativity: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_assortativity.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

$(BIN_DIR)/graph_centralization: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_centralization.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

$(BIN_DIR)/graph_clustering: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_clustering.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

$(BIN_DIR)/graph_connectivity: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_connectivity.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

$(BIN_DIR)/graph_degree: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_degree.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

$(BIN_DIR)/graph_density: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_density.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

$(BIN_DIR)/graph_reciprocity: $(OBJ_DIR)/graph.o $(OBJ_DIR)/graph_reciprocity.o
	$(CXX) $(CXX_FLAGS) $^ -o $@ $(LD_FLAGS)

all: $(BIN_DIR)/graph_assortativity \
	$(BIN_DIR)/graph_centralization \
	$(BIN_DIR)/graph_clustering \
	$(BIN_DIR)/graph_connectivity \
	$(BIN_DIR)/graph_degree \
	$(BIN_DIR)/graph_density \
	$(BIN_DIR)/graph_reciprocity \
	classes

clean:
	$(RM) -rf $(OBJ_DIR) $(BIN_DIR)