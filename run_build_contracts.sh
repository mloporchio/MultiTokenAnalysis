#!/bin/bash

BUILDER_NAME="build_contracts.py"
TRANSFERS_FILE="data/erc1155_transfers.parquet"
OUTPUT_DIR="results/contracts"

mkdir -p $OUTPUT_DIR

python3 $BUILDER_NAME $TRANSFERS_FILE $OUTPUT_DIR