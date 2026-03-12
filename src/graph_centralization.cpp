/**
 * @file graph_centralization.cpp
 * @author Matteo Loporchio
 * @date 2025-06-29
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

    // Compute the in-degree and out-degree centralization.
    igraph_real_t in_cent, out_cent;
    igraph_centralization_degree(&graph, NULL, IGRAPH_IN, 0, &in_cent, NULL, 1);
    igraph_centralization_degree(&graph, NULL, IGRAPH_OUT, 0, &out_cent, NULL, 1);

    // Free the memory occupied by the graph.
    igraph_destroy(&graph);
    igraph_vector_destroy(&w_ntr);
    igraph_vector_destroy(&w_ntk);

    // Print information to stdout.
    auto end = high_resolution_clock::now();
    auto elapsed = duration_cast<nanoseconds>(end - start);
    cout << num_nodes << '\t' 
        << num_edges << '\t' 
        << in_cent << '\t'
        << out_cent << '\t' 
        << elapsed.count() << '\n';
    return 0;
}