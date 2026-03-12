#!/bin/bash
#
#   This script iterates through all ERC-1155 contracts and builds the associated Token Transfer Graphs
#   based on their lists of transfers. For each graph, the script then computes the
#   in-degree and out-degree centralization indices and writes the results to a TSV file.
#
#   The output TSV file contains one row per contract with the following fields:
#   - contract_id: numerical identifier of the contract;
#   - address: address of the contract;
#   - num_nodes: number of nodes in the graph;
#   - num_edges: number of edges in the graph;
#   - in_cent: in-degree centralization index;
#   - out_cent: out-degree centralization index.
#
#   Author: Matteo Loporchio
#

BUILDER="build_graph.py"
RANKING_FILE="results/ranking.tsv"
INPUT_DIR="results/contracts"
OUTPUT_FILE="results/graph_centralization.tsv"
TEMP_DIR="tmp"
BIN_DIR="bin"

mkdir -p "${TEMP_DIR}"

printf "contract_id\taddress\tnum_nodes\tnum_edges\tin_cent\tout_cent\n" > $OUTPUT_FILE
while IFS=$'\t' read -r CONTRACT_ID ADDRESS NUM_TRANSFER; do
    echo "Processing contract ${CONTRACT_ID}..."
    CONTRACT_FILE="${INPUT_DIR}/contract_${CONTRACT_ID}.json"
    NM_FILE="${TEMP_DIR}/nm_${CONTRACT_ID}.tsv"
    EL_FILE="${TEMP_DIR}/el_${CONTRACT_ID}.tsv"
    # Build the graph for the contract.
    echo "Building the graph..."
    (python3 "${BUILDER}" "${CONTRACT_FILE}" "${NM_FILE}" "${EL_FILE}") 1> /dev/null 2>&1
    # Analyze the graph and compute the in-degree and out-degree centralization indices.
    echo "Analyzing centralization..."
    CENT_OUTPUT=$(./${BIN_DIR}/graph_centralization "${EL_FILE}")
    NUM_NODES=$(echo "${CENT_OUTPUT}" | cut -d$'\t' -f1)
    NUM_EDGES=$(echo "${CENT_OUTPUT}" | cut -d$'\t' -f2)
    IN_CENT=$(echo "${CENT_OUTPUT}" | cut -d$'\t' -f3)
    OUT_CENT=$(echo "${CENT_OUTPUT}" | cut -d$'\t' -f4)
    # Write the results to the output file.
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "${CONTRACT_ID}" "${ADDRESS}" "${NUM_NODES}" "${NUM_EDGES}" "${IN_CENT}" "${OUT_CENT}" >> "${OUTPUT_FILE}"
    # Delete the graph files.
    rm -f "${NM_FILE}" "${EL_FILE}"
    echo "Done!"
done < <(tail -n +2 "${RANKING_FILE}")  # Skip the header line in the ranking file.

rm -rf "${TEMP_DIR}"
