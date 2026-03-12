/**
 * @file graph_density.cpp
 * @author Matteo Loporchio
 * @date 2025-06-20
 * 
 *  This program reads the Token Transfer Graph from a file and computes its density.
 *  Density is defined as the ratio between the actual number of edges and  
 *  the largest possible number of edges the graph could have.
 *
 *  INPUT:
 *  The weighted edge list for Token Transfer Graph.
 *
 *  OUTPUT:
 *  No output file is produced.
 *
 *  PRINT:
 *  The program prints the following information to stdout:
 *      - number of graph nodes;
 *      - number of graph edges;
 *      - density of the graph;
 *      - elapsed time (in nanoseconds).
 */

#include <chrono>
#include <iostream>
#include "graph.hpp"

using namespace std;
using namespace std::chrono;

int main(int argc, char **argv) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <input_file>\n";
        return 1;
    }
    auto start = high_resolution_clock::now();

    // Load the graph from the corresponding file.
    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        cerr << "Error: could not open input file!\n";
        return 1;
    }
    igraph_t graph;
    igraph_vector_t w_ntr; // stores weights (total number of transfers)
    igraph_vector_t w_ntk; // stores weights (number of unique tokens transferred)
    igraph_vector_init(&w_ntr, 0);
    igraph_vector_init(&w_ntk, 0);
    read_ttg(&graph, &w_ntr, &w_ntk, input_file);
    fclose(input_file);

    // Obtain the number of nodes and edges.
    igraph_integer_t num_nodes = igraph_vcount(&graph);
    igraph_integer_t num_edges = igraph_ecount(&graph);

    // Compute the density.
    igraph_real_t density;
    igraph_density(&graph, &density, 0);

    // Free the memory occupied by the graph.
    igraph_destroy(&graph);
    igraph_vector_destroy(&w_ntr);
    igraph_vector_destroy(&w_ntk);
    
    // Print information to stdout.
    auto end = high_resolution_clock::now();
    auto elapsed = duration_cast<nanoseconds>(end - start);
    cout << num_nodes << '\t' 
        << num_edges << '\t' 
        << density << '\t' 
        << elapsed.count() << '\n';
    return 0;
}


