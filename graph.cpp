/**
 * @file graph.cpp
 * @author Matteo Loporchio
 * @date 2025-02-21
 *  
 *  This file contains the implementation of functions for reading graphs from text files.
 *  Graphs are imported and managed using the igraph library.
 *  The currently supported graph models are:
 *
 *  1) Token Transfer Graph, i.e., a weighted directed graph where:
 *      - each node represents an Ethereum address;
 *      - each edge (u, v) represents all transfers from address u to address v.
 *      - each edge is labeled with:
 *          - total number of transfers from u to v;
 *          - number of unique tokens transferred from u to v;
 */

#include "graph.hpp"
#include <algorithm>
#include <cstdlib>
#include <cstring>

/**
 * @brief Reads the Token Transfer Graph edge list from a file and builds the corresponding graph.
 * 
 * @param graph stores the final graph
 * @param w_ntr stores the final weight vector (with total number of transfers for each edge)
 * @param w_ntk stores the final weight vector (with number of unique tokens transferred for each edge)
 * @param input_file text file containing the list of weighted edges
 */
void read_ttg(igraph_t *graph, igraph_vector_t *w_ntr, igraph_vector_t *w_ntk, FILE *input_file) {
    igraph_vector_int_t edges;
    igraph_vector_int_init(&edges, 0);
    //igraph_vector_int_reserve(&edges, 1000000*2);
    int max_node_id = 0;
    char *line_buf = NULL;
    size_t line_size = 0;
    while (getline(&line_buf, &line_size, input_file) > 0) {
        char *token = NULL;
        int token_count = 0;
        int from, to;
        double num_transfers, num_tokens;
        while ((token = strsep(&line_buf, "\t"))) {
            if (token_count == 0) from = atoi(token); // 0: from
            if (token_count == 1) to = atoi(token); // 1: to
            if (token_count == 2) num_transfers = atof(token); // 2: number of transfers
            if (token_count == 3) num_tokens = atof(token); // 3: number of unique tokens
            token_count++;
        }
        igraph_vector_int_push_back(&edges, from);
        igraph_vector_int_push_back(&edges, to);
        igraph_vector_push_back(w_ntr, num_transfers);
        igraph_vector_push_back(w_ntk, num_tokens);
        max_node_id = std::max({max_node_id, from, to});
    }
    int num_nodes = max_node_id + 1;
    igraph_empty(graph, num_nodes, IGRAPH_DIRECTED);
    igraph_add_edges(graph, &edges, NULL);
    igraph_vector_int_destroy(&edges);
}
