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
#   - contract_id: numerical identifier of the contract (in the range [0, 99]);  
#   - num_nodes: number of nodes in the graph;  
#   - num_edges: number of edges in the graph;  
#   - elapsed_time: time taken for construction (in nanoseconds).  
#
#   Author: Matteo Loporchio
#

NUM_CONTRACTS=100
BUILDER="build_graph.py"
INPUT_DIR="results/contracts"
GRAPH_DIR="results/graphs"
TEMP_DIR="tmp"
WEBGRAPH_DIR="results/webgraphs"
WEBGRAPH_BUILDER="WebGraphBuilder"
OUTPUT_FILE="results/graph_creation.tsv"

# Create the output directories, if needed.
mkdir -p $GRAPH_DIR $WEBGRAPH_DIR $TEMP_DIR

printf "contract_id\tnum_nodes\tnum_edges\telapsed_time\n" > $OUTPUT_FILE
for ((i = 0 ; i < $NUM_CONTRACTS ; i++)); do
    echo "Building graph for contract ${i}..."
    CONTRACT_FILE="${INPUT_DIR}/contract_${i}.json"
    NM_FILE="${GRAPH_DIR}/nm_${i}.tsv"
    EL_FILE="${GRAPH_DIR}/el_${i}.tsv"
    TEMP_EL_FILE="${WEBGRAPH_DIR}/tmp_${i}.tsv"
    WEBGRAPH_OUTPUT="${WEBGRAPH_DIR}/webgraph_${i}"
    printf "%d\t" $i >> $OUTPUT_FILE
    # First, transform each contract event list into an edge list.
    python3 ${BUILDER} ${CONTRACT_FILE} ${NM_FILE} ${EL_FILE} >> $OUTPUT_FILE
    # Transform each edge list into the WebGraph BVGraph format.
    cut -d$'\t' -f1,2 ${EL_FILE} > ${TEMP_EL_FILE}
    java -Xmx128g -cp "bin:lib/*" ${WEBGRAPH_BUILDER} ${TEMP_EL_FILE} ${WEBGRAPH_OUTPUT}
    rm ${TEMP_EL_FILE} # Delete temporary edge list
    echo "Done!"
done

# Delete the temporary directory.
rm -rf $TEMP_DIR