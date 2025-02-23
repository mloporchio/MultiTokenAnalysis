#!/bin/bash
#
#   This script reads the list of ERC-1155 transfers associated with each contract (in CSV format)
#   and constructs the weighted directed graph of the contract.
#   The transfer lists must be in the CSV format produced by the "create_contracts.py" script.
#   
#   More precisely, this script:
#   1) Constructs the weighted directed graph to be used with the igraph library;
#   2) Constructs the unweighted directed graph to be used with the WebGraph library;
#
#   Graph (2) is obtained from graph (1) by removing all weights associated with the edges.
#   This step is necessary because WebGraph does not support operations on weighted graphs.
#
#   INPUT:
#   - Path of the directory containing all contract transfer lists in CSV format.
#
#   OUTPUT:
#   The script outputs a TSV file that describes the main characteristics of the graph for each contract. 
#   The file contains one row per contract with the following fields:  
#   - **contract_id**: numerical identifier of the contract (in the range [0, 99]);  
#   - **num_nodes**: number of nodes in the graph;  
#   - **num_edges**: number of edges in the graph;  
#   - **elapsed_time**: time taken for construction (in nanoseconds).  
#
#   Author: Matteo Loporchio
#

BUILDER_NAME="GraphBuilder"
INPUT_DIR="results/contracts"
GRAPH_DIR="results/graphs"
WEBGRAPH_DIR="results/webgraphs"
WEBGRAPH_BUILDER="WebGraphBuilder"
OUTPUT_FILE="results/graph_creation.tsv"

printf "contract_id\tnum_nodes\tnum_edges\telapsed_time\n" > $OUTPUT_FILE
for i in {0..99}; do
    WEBGRAPH_TEMP_EL="tmp_${i}.tsv"
    printf "%d\t" $i >> $OUTPUT_FILE
    # First, transform each contract event list into an edge list.
    java -Xmx128g ${BUILDER_NAME} "${INPUT_DIR}/contract_${i}.csv" "${GRAPH_DIR}/el_${i}.tsv" "${GRAPH_DIR}/nm_${i}.tsv" >> $OUTPUT_FILE
    # Then, transform each edge list into the WebGraph BVGraph format.
    cut -d$'\t' -f1,2 "${GRAPH_DIR}/el_${i}.tsv" > "${WEBGRAPH_DIR}/${WEBGRAPH_TEMP_EL}"
    java -Xmx128g ${WEBGRAPH_BUILDER} "${WEBGRAPH_DIR}/${WEBGRAPH_TEMP_EL}" "${WEBGRAPH_DIR}/webgraph_${i}"
    rm "${WEBGRAPH_DIR}/${WEBGRAPH_TEMP_EL}" # Delete temporary edge list
done