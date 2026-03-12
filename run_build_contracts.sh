#!/bin/bash
# 
#   This script reads the dataset of ERC-1155 transfers and constructs the list of transfers 
#   for all the contracts in the dataset. 
#   
#   The list of transfers is stored in newline-delimited JSON format, with one file per contract.
#   
#   Author: Matteo Loporchio
#

BUILDER_NAME="build_contracts.py"
TRANSFERS_FILE="data/erc1155_transfers.parquet"
OUTPUT_DIR="results/contracts"
RANKING_FILE="results/ranking.tsv"

mkdir -p $OUTPUT_DIR

python3 $BUILDER_NAME $TRANSFERS_FILE $OUTPUT_DIR $RANKING_FILE