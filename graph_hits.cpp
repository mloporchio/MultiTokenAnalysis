/**
 * @file graph_hits.cpp
 * @author Matteo Loporchio
 * @date 2025-05-21
 *
 *  This program reads the weighted edge list of the Token Transfer Graph (in TSV format)
 *  and computes the Hub and Authority scores for all nodes.
 *  
 *  The output is written to a TSV file.
 *
 *  Specifically, the program computes five Hub and Authority scores for each node:
 *      - Hub score with unweighted edges;
 *      - Authority score with unweighted edges;
 *      - Hub score with total number of transfers as edge weight;
 *      - Authority score with total number of transfers as edge weight;
 *      - Hub score with number of unique tokens transferred as edge weight;
 *      - Authority score with number of unique tokens transferred as edge weight;
 *
 *  INPUT:
 *  The edge list for the collapsed graph (in TSV format).
 *
 *  OUTPUT:
 *  A TSV file summarizing the Hub and Authority scores for each node.
 *  The output file contains one line for each node and each line includes the following fields:
 *      - numeric identifier of the node;
 *      - Hub score of the node (with unweighted edges);
 *      - Authority score of the node (with unweighted edges);
 *      - Hub score of the node (with total number of transfers as edge weight);
 *      - Authority score of the node (with total number of transfers as edge weight);
 *      - Hub score of the node (with number of unique tokens transferred as edge weight);
 *      - Authority score of the node (with number of unique tokens transferred as edge weight);
 *
 *  PRINT:
 *  The program prints the following information to stdout:
 *      - number of graph nodes;
 *      - number of graph edges;
 *      - elapsed time (in nanoseconds).
 */

#include <chrono>
#include <iostream>
#include "graph.hpp"

using namespace std;
using namespace std::chrono;

int main(int argc, char **argv) {
    if (argc < 3) {
        cerr << "Usage: " << argv[0] << " <input_file> <output_file>\n";
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

    // Compute Hub and Authority scores.
    igraph_vector_t hub, hub_ntr, hub_ntk, auth, auth_ntr, auth_ntk;
    igraph_vector_init(&hub, num_nodes);
    igraph_vector_init(&hub_ntr, num_nodes);
    igraph_vector_init(&hub_ntk, num_nodes);
    igraph_vector_init(&auth, num_nodes);
    igraph_vector_init(&auth_ntr, num_nodes);
    igraph_vector_init(&auth_ntk, num_nodes);
    igraph_hub_and_authority_scores(&graph, &hub, &auth, NULL, 0, NULL, NULL);
    igraph_hub_and_authority_scores(&graph, &hub_ntr, &auth_ntr, NULL, 0, NULL, NULL);
    igraph_hub_and_authority_scores(&graph, &hub_ntk, &auth_ntk, NULL, 0, NULL, NULL);
 
    // Write the results to the output TSV file.
    FILE *output_file = fopen(argv[2], "w");
    if (!output_file) {
        cerr << "Error: could not open output file!\n";
        return 1;
    }
    fprintf(output_file, "node_id\thub\tauth\thub_ntr\tauth_ntr\thub_ntk\tauth_ntk\n");
    for (int i = 0; i < num_nodes; i++) {
        double h = VECTOR(hub)[i];
        double a = VECTOR(auth)[i];
        double h_ntr = VECTOR(hub_ntr)[i];
        double a_ntr = VECTOR(auth_ntr)[i];
        double h_ntk = VECTOR(hub_ntk)[i];
        double a_ntk = VECTOR(auth_ntk)[i];
        fprintf(output_file, "%d\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\n", 
            i, h, a, h_ntr, a_ntr, h_ntk, a_ntk);
    }
    fclose(output_file);

    // Free the memory occupied by the graph.
    igraph_destroy(&graph);
    igraph_vector_destroy(&hub);
    igraph_vector_destroy(&hub_ntr);
    igraph_vector_destroy(&hub_ntk);
    igraph_vector_destroy(&auth);
    igraph_vector_destroy(&auth_ntr);
    igraph_vector_destroy(&auth_ntk);

    auto end = high_resolution_clock::now();
    auto elapsed = duration_cast<nanoseconds>(end - start);

    // Print information about the program execution. 
    cout << num_nodes << '\t' << num_edges << '\t' << elapsed.count() << '\n';
    return 0;
}

