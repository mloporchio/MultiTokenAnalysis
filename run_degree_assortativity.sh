#!/bin/bash
# This script computes the assortativity of the degree distribution of the graphs.
# Author: Matteo Loporchio
#

INPUT_FILE="results/graph_creation.tsv"
INPUT_DIR="results/graphs"
OUTPUT_FILE="results/graph_assortativity_all.tsv"

printf "contract_id\tnum_nodes\tnum_edges\tin_in\tin_out\tout_in\tout_out\telapsed\n" > $OUTPUT_FILE
CONTRACT_IDS=( $(cut -d$'\t' -f1 ${INPUT_FILE} | tail -n +2 | tr '\n' ' ') )
for i in "${CONTRACT_IDS[@]}"; do
    echo "Processing contract $i..."
    INPUT_FILE="${INPUT_DIR}/el_${i}.tsv"
    printf "%s\t" "$i" >> $OUTPUT_FILE
    ./graph_assortativity_all ${INPUT_FILE} >> $OUTPUT_FILE
    echo "Done!"
done
