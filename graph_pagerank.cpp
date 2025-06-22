/**
 * @file graph_pagerank.cpp
 * @author Matteo Loporchio
 * @date 2025-05-15
 *
 *  This program reads the weighted edge list of the Token Transfer Graph (in TSV format)
 *  and computes the PageRank for all nodes.
 *
 *  The PageRank is computed with a default damping factor of 0.85.
 *
 *  Specifically, the program computes three PageRank scores for each node:
 *      - PageRank with unweighted edges;
 *      - PageRank computed considering the total number of transfers as edge weight;
 *      - PageRank computed considering the number of unique tokens transferred as edge weight;
 *
 *  INPUT:
 *  The edge list for the collapsed graph (in TSV format).
 *
 *  OUTPUT:
 *  A TSV file summarizing the PageRank for each node.
 *  The output file contains one line for each node and each line includes the following fields:
 *      - numeric identifier of the node;
 *      - PageRank of the node (with unweighted edges);
 *      - PageRank of the node considering the total number of transfers as edge weight;
 *      - PageRank of the node considering the number of unique tokens transferred as edge weight;
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

#define DAMPING_FACTOR 0.85 // default damping factor for PageRank

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

    // Compute PageRank.
    igraph_vector_t pagerank, pagerank_ntr, pagerank_ntk;
    igraph_vector_init(&pagerank, num_nodes);
    igraph_vector_init(&pagerank_ntr, num_nodes);
    igraph_vector_init(&pagerank_ntk, num_nodes);
    igraph_pagerank(&graph, IGRAPH_PAGERANK_ALGO_PRPACK, &pagerank, NULL, igraph_vss_all(), IGRAPH_DIRECTED, DAMPING_FACTOR, NULL, NULL);
    igraph_pagerank(&graph, IGRAPH_PAGERANK_ALGO_PRPACK, &pagerank_ntr, NULL, igraph_vss_all(), IGRAPH_DIRECTED, DAMPING_FACTOR, &w_ntr, NULL);
    igraph_pagerank(&graph, IGRAPH_PAGERANK_ALGO_PRPACK, &pagerank_ntk, NULL, igraph_vss_all(), IGRAPH_DIRECTED, DAMPING_FACTOR, &w_ntk, NULL);

    // Write the results to the output TSV file.
    FILE *output_file = fopen(argv[2], "w");
    if (!output_file) {
        cerr << "Error: could not open output file!\n";
        return 1;
    }
    fprintf(output_file, "node_id\tpagerank\ttpagerank_ntr\ttpagerank_ntk\n");
    for (int i = 0; i < num_nodes; i++) {
        double p = VECTOR(pagerank)[i];
        double p_ntr = VECTOR(pagerank_ntr)[i];
        double p_ntk = VECTOR(pagerank_ntk)[i];
        fprintf(output_file, "%d\t%.15f\t%.15f\t%.15f\n", i, p, p_ntr, p_ntk); 
    }
    fclose(output_file);

    // Free the memory occupied by the graph.
    igraph_destroy(&graph);
    igraph_vector_destroy(&pagerank);
    igraph_vector_destroy(&pagerank_ntr);
    igraph_vector_destroy(&pagerank_ntk);
    
    auto end = high_resolution_clock::now();
    auto elapsed = duration_cast<nanoseconds>(end - start);

    // Print information about the program execution. 
    cout << num_nodes << '\t' << num_edges << '\t' << elapsed.count() << '\n';
    return 0;
}

