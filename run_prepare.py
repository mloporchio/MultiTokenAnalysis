#   
#   This script converts the original dataset of ERC-1155 transfers (stored in compressed JSON format)
#   into the Parquet format for subsequent analysis. 
#
#   Author: Matteo Loporchio
#

import polars as pl
import os
import time

INPUT_FILE = "data/erc1155_transfers.json.gz"
OUTPUT_FILE = "data/erc1155_transfers.parquet"

if __name__ == "__main__":
    if not os.path.exists(INPUT_FILE):
        print(f"Error: Input dataset {INPUT_FILE} not found.")
        print("Please download the dataset and place it in the \"data\" directory.")
        exit(1)

    print(f"Reading dataset from {INPUT_FILE}...")
    start_time = time.time()
    df = pl.read_json(INPUT_FILE)
    elapsed = time.time() - start_time
    print(f"Done! (took {elapsed:.2f} s)")

    print(f"Converting dataset to {OUTPUT_FILE}...")
    start_time = time.time()
    df.write_parquet(OUTPUT_FILE)
    elapsed = time.time() - start_time
    print(f"Done! (took {elapsed:.2f} s)")