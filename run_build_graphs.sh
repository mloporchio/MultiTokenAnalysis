#!/bin/bash
#
#   This script builds the Token Transfer Graph of each ERC-1155 contract in accordance
#   to the list of its transfers. 
#
#   First, the script produces two text files for each contract: 
#   1) a node map file that associates each node in the graph to its real Ethereum address;
#   2) an edge list file that describes the edges of the graph in terms of source node, target node and weight.
#
#   The edge list file is then transformed into the BVGraph format to be used with the WebGraph library.
#
#   NOTICE: For space reasons, the script only builds the graphs of the contracts whose 
#   in-degree and out-degree centralization indices are different from 1. 
#   This information is retrieved from the "results/centralization.tsv" file,
#   which is produced by the `run_centralization.sh` script. 
#
#   OUTPUT:
#   The script outputs a TSV file that describes the main characteristics of each constructed graph.
#   The file has the following structure:
#
#   <contract_id>\t<address>\t<num_nodes>\t<num_edges>\t<elapsed_time>
#
#   where:
#   - contract_id: numerical identifier of the contract;
#   - address: address of the contract;
#   - num_nodes: number of nodes in the graph;
#   - num_edges: number of edges in the graph;
#   - elapsed_time: time taken for construction (in nanoseconds).
#
#   Author: Matteo Loporchio
#

BUILDER="build_graph.py"
INPUT_DIR="results/contracts"
GRAPH_DIR="results/graphs"
TEMP_DIR="tmp"
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