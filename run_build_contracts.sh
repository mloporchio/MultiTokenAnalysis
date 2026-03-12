#!/bin/bash
# 
#   This script takes the input dataset of ERC-1155 transfers 
#   and builds the corresponding interaction graphs for the top 100 contracts, as well as a ranking of the contracts based on their activity.
#   
#   Author: Matteo Loporchio
#

BUILDER_NAME="build_contracts.py"
TRANSFERS_FILE="data/erc1155_transfers.parquet"
OUTPUT_DIR="results/contracts"
RANKING_FILE="results/ranking.tsv"

mkdir -p $OUTPUT_DIR

python3 $BUILDER_NAME $TRANSFERS_FILE $OUTPUT_DIR $RANKING_FILE