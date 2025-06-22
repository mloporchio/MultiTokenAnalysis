/**
 * @file graph.hpp
 * @author Matteo Loporchio
 * @date 2025-02-21
 * 
 *  This file contains the definitions of functions for reading graphs from text files.
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

#ifndef GRAPH_H
#define GRAPH_H

#include <cstdio>
#include <igraph.h>

/**
 * @brief Reads the Token Transfer Graph edge list from a file and builds the corresponding graph.
 * 
 * @param graph stores the final graph
 * @param w_ntr stores the final weight vector (with total number of transfers for each edge)
 * @param w_ntk stores the final weight vector (with number of unique tokens transferred for each edge)
 * @param input_file text file containing the list of weighted edges
 */
void read_ttg(igraph_t *graph, igraph_vector_t *w_ntr, igraph_vector_t *w_ntk, FILE *input_file);

#endif