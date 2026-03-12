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

BUILDER="build_graph.py"
INPUT_DIR="results/contracts"
GRAPH_DIR="results/graphs"
TEMP_DIR="temp"
WEBGRAPH_DIR="results/webgraphs"
WEBGRAPH_BUILDER="WebGraphBuilder"
CENT_FILE="results/centralization.tsv"
SELECTED_LIST_FILE="${TEMP_DIR}/selected.tsv"
OUTPUT_FILE="results/graph_creation.tsv"
BIN_DIR="bin"
LIB_DIR="lib"
CLASSPATH="${BIN_DIR}:${LIB_DIR}/*"

# Create the output directories, if needed.
mkdir -p $GRAPH_DIR $WEBGRAPH_DIR $TEMP_DIR

# Select the contracts with in-degree and out-degree centralization index different from 1.
# Write the list of selected contracts to a temporary file.
python3 - <<END
import polars as pl
df = pl.read_csv('${CENT_FILE}', separator='\t')
result = df.filter((pl.col("in_cent") != 1) & (pl.col("out_cent") != 1))
result = result.select('contract_id', 'address', 'in_cent', 'out_cent')
result.write_csv('${SELECTED_LIST_FILE}', separator='\t', include_header=False)
END

# Read the list of selected contracts. 
# For each contract, build the corresponding graph and write it to a file.
printf "contract_id\taddress\tnum_nodes\tnum_edges\telapsed_time\n" > $OUTPUT_FILE
while IFS=$'\t' read -r i address in_cent out_cent; do
    echo "Building graph for contract ${i}..."
    CONTRACT_FILE="${INPUT_DIR}/contract_${i}.json"
    NM_FILE="${GRAPH_DIR}/nm_${i}.tsv"
    EL_FILE="${GRAPH_DIR}/el_${i}.tsv"
    TEMP_EL_FILE="${WEBGRAPH_DIR}/tmp_${i}.tsv"
    WEBGRAPH_OUTPUT="${WEBGRAPH_DIR}/webgraph_${i}"
    printf "%d\t%s\t" $i $address >> $OUTPUT_FILE
    # First, transform each contract event list into an edge list.
    python3 ${BUILDER} ${CONTRACT_FILE} ${NM_FILE} ${EL_FILE} >> $OUTPUT_FILE
    # Transform each edge list into the WebGraph BVGraph format.
    cut -d$'\t' -f1,2 ${EL_FILE} > ${TEMP_EL_FILE}
    java -Xmx128g -cp "${CLASSPATH}" ${WEBGRAPH_BUILDER} ${TEMP_EL_FILE} ${WEBGRAPH_OUTPUT}
    rm ${TEMP_EL_FILE} # Delete temporary edge list
    echo "Done!"
done < "${SELECTED_LIST_FILE}"

# Delete the temporary directory.
rm -rf $TEMP_DIR