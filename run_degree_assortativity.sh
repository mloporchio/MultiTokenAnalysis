#!/bin/bash
#
#   This script computes the assortativity of the degree distributions of the ERC-1155 Token Transfer Graphs.
#
#   Graphs are considered as unweighted and all possible combinations of in-degree and out-degree are analyzed.
#
#   The script produces a TSV file with the following fields:
#   - contract_id: numerical identifier of the contract;
#   - num_nodes: number of nodes in the graph;
#   - num_edges: number of edges in the graph;
#   - in_in: IN-IN assortativity coefficient;
#   - in_out: IN-OUT assortativity coefficient;
#   - out_in: OUT-IN assortativity coefficient;
#   - out_out: OUT-OUT assortativity coefficient;
#   - elapsed: time taken for the computation (in nanoseconds).
#   
#   Author: Matteo Loporchio
#

INPUT_FILE="results/graph_creation.tsv"
INPUT_DIR="results/graphs"
OUTPUT_FILE="results/graph_assortativity_all.tsv"
BIN_DIR="bin"

printf "contract_id\tnum_nodes\tnum_edges\tin_in\tin_out\tout_in\tout_out\telapsed\n" > $OUTPUT_FILE
CONTRACT_IDS=( $(cut -d$'\t' -f1 ${INPUT_FILE} | tail -n +2 | tr '\n' ' ') )
for i in "${CONTRACT_IDS[@]}"; do
    echo "Processing contract $i..."
    INPUT_FILE="${INPUT_DIR}/el_${i}.tsv"
    printf "%s\t" "$i" >> $OUTPUT_FILE
    ./${BIN_DIR}/graph_assortativity ${INPUT_FILE} >> $OUTPUT_FILE
    echo "Done!"
done
