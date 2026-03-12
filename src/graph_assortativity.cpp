/**
 * @file graph_assortativity.cpp
 * @author Matteo Loporchio
 * @date 2025-06-20
 * 
 *  This program reads the weighted edge list of the Token Transfer Graph 
 *  and computes the degree assortativity of the graph. 
 *
 *  INPUT:
 *  The weighted edge list of the Token Transfer Graph.
 *
 *  OUTPUT:
 *  No output file is produced.
 *
 *  PRINT:
 *  The program prints the following information to stdout:
 *      - number of graph nodes;
 *      - number of graph edges;
 *      - unweighted degree assortativity of the graph;
 *      - weighted (OUT-IN) assortativity coefficient based on the total number of transfers;
 *      - weighted (OUT-IN) assortativity coefficient based on the number of unique tokens transferred;
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

    // Compute the unweighted degree assortativity.
    igraph_real_t assort;
    igraph_assortativity_degree(&graph, &assort, IGRAPH_DIRECTED);

    // Compute the strength of the nodes and weighted (OUT-IN) assortativity coefficients.
    igraph_real_t assort_ntr, assort_ntk;
    igraph_vector_t in_str_ntr, out_str_ntr, in_str_ntk, out_str_ntk;
    igraph_vector_init(&in_str_ntr, num_nodes);
    igraph_vector_init(&out_str_ntr, num_nodes);
    igraph_vector_init(&in_str_ntk, num_nodes);
    igraph_vector_init(&out_str_ntk, num_nodes);
    igraph_strength(&graph, &in_str_ntr, igraph_vss_all(), IGRAPH_IN, 0, &w_ntr);
    igraph_strength(&graph, &out_str_ntr, igraph_vss_all(), IGRAPH_OUT, 0, &w_ntr);
    igraph_strength(&graph, &in_str_ntk, igraph_vss_all(), IGRAPH_IN, 0, &w_ntk);
    igraph_strength(&graph, &out_str_ntk, igraph_vss_all(), IGRAPH_OUT, 0, &w_ntk);
    igraph_assortativity(&graph, &out_str_ntr, &in_str_ntr, &assort_ntr, IGRAPH_DIRECTED, 1);
    igraph_assortativity(&graph, &out_str_ntk, &in_str_ntk, &assort_ntk, IGRAPH_DIRECTED, 1);

    // Free the memory occupied by the graph.
    igraph_destroy(&graph);
    igraph_vector_destroy(&w_ntr);
    igraph_vector_destroy(&w_ntk);

    // Print information to stdout.
    auto end = high_resolution_clock::now();
    auto elapsed = duration_cast<nanoseconds>(end - start);
    cout << num_nodes << '\t' 
        << num_edges << '\t' 
        << assort << '\t' 
        << assort_ntr << '\t'
        << assort_ntk << '\t'
        << elapsed.count() << '\n';
    return 0;
}