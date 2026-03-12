/**
 * @file graph_assortativity.cpp
 * @author Matteo Loporchio
 * @date 2025-06-20
 *
 *  This program reads the weighted edge list of the Token Transfer Graph 
 *  and computes the degree assortativity of the graph. Note that the graph is considered as unweighted 
 *  and possible combinations of IN and OUT degree are considered.
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
 *      - IN-IN assortativity coefficient;
 *      - IN-OUT assortativity coefficient;
 *      - OUT-IN assortativity coefficient;
 *      - OUT-OUT assortativity coefficient;
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

    // Compute the degree.
    igraph_vector_int_t in_deg_v, out_deg_v;
    igraph_vector_int_init(&in_deg_v, num_nodes);
    igraph_vector_int_init(&out_deg_v, num_nodes);
    igraph_degree(&graph, &in_deg_v, igraph_vss_all(), IGRAPH_IN, 1);
    igraph_degree(&graph, &out_deg_v, igraph_vss_all(), IGRAPH_OUT, 1);

    // Convert degree vectors to double precision for assortativity computation.
    igraph_vector_t in_deg, out_deg;
    igraph_vector_init(&in_deg, num_nodes);
    igraph_vector_init(&out_deg, num_nodes);
    for (igraph_integer_t i = 0; i < num_nodes; ++i)
    {
        VECTOR(in_deg)[i] = (double)VECTOR(in_deg_v)[i];
        VECTOR(out_deg)[i] = (double)VECTOR(out_deg_v)[i];
    }

    // Compute the unweighted assortativity coefficients.
    igraph_real_t ii_a, io_a, oi_a, oo_a;
    igraph_assortativity(&graph, &in_deg, &in_deg, &ii_a, IGRAPH_DIRECTED, 1);
    igraph_assortativity(&graph, &in_deg, &out_deg, &io_a, IGRAPH_DIRECTED, 1);
    igraph_assortativity(&graph, &out_deg, &in_deg, &oi_a, IGRAPH_DIRECTED, 1);
    igraph_assortativity(&graph, &out_deg, &out_deg, &oo_a, IGRAPH_DIRECTED, 1);

    // Free the memory occupied by the data structures used.
    igraph_destroy(&graph);
    igraph_vector_destroy(&w_ntr);
    igraph_vector_destroy(&w_ntk);
    igraph_vector_int_destroy(&in_deg_v);
    igraph_vector_int_destroy(&out_deg_v);
    igraph_vector_destroy(&in_deg);
    igraph_vector_destroy(&out_deg);

    // Print information to stdout.
    auto end = high_resolution_clock::now();
    auto elapsed = duration_cast<nanoseconds>(end - start);
    cout << num_nodes << '\t' 
        << num_edges << '\t' 
        << ii_a << '\t' 
        << io_a << '\t'
        << oi_a << '\t'
        << oo_a << '\t'
        << elapsed.count() << '\n';
    return 0;
}