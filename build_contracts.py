#
#   This script processes the dataset of ERC-1155 transfers and builds a separate file for each contract.
#   Each file contains the list of transfers triggered by the corresponding contract, in newline-delimited JSON format.
#
#   The script also computes a ranking of the contracts based on the number of transfers they triggered 
#   and writes the ranking to a separate TSV file.
#
#   INPUT:
#   - The dataset of ERC-1155 transfers in Parquet format (see `run_prepare.py`).
#   - The output directory where the files for each contract will be written.
#   - The file where the contract ranking will be written.
#
#   OUTPUT:
#   - A separate file JSON file for each ERC-1155 contract, containing the list of transfers triggered by that contract.
#   - A TSV file containing the ranking of the contracts based on the number of transfers they triggered.
#   
#   Note that the TSV ranking file has the following format
#   <contract_id>\t<address>\t<num_transfer>
#   where:
#      - contract_id is a unique integer identifier for each contract (starting from 0).
#      - address is the address of the contract.
#      - num_transfer is the number of transfers triggered by the contract.
#
#   Author: Matteo Loporchio
#

import polars as pl
import sys
import utils

TRANSFERS_FILE = sys.argv[1]
OUTPUT_DIR = sys.argv[2]
RANKING_FILE = sys.argv[3]
NULL_ADDRESS = "0x0000000000000000000000000000000000000000"

# Read the transfers dataset and remove all non-standard transfer events.
df = pl.read_parquet(TRANSFERS_FILE)
tdf = utils.filter_transfers(df)
tdf = tdf.explode(['token_ids', 'amounts'])

# Remove all transfers originating from the 0x0 address (i.e., mint) and those directed to 0x0 (i.e., burn).
# Filter also all self-transfers (i.e., those where sender and receiver coincide).
tdf = tdf.filter((pl.col('from') != NULL_ADDRESS) & (pl.col('to') != NULL_ADDRESS) & (pl.col('from') != pl.col('to')))

# Compute the contract ranking based on the number of raised transfers and write the ranking to a file.
ranking = tdf.group_by('address').len().sort(by='len', descending=True).rename({'len': 'num_transfer'})
fh = open(RANKING_FILE, 'w')
fh.write('contract_id\taddress\tnum_transfer\n')
contract_id = 0
contract_mapping = dict()
for row in ranking.iter_rows(named=True):
    contract_address = row['address']
    num_transfers = row['num_transfer']
    fh.write(f'{contract_id}\t{contract_address}\t{num_transfers}\n')
    contract_mapping[contract_address] = contract_id
    contract_id += 1
fh.close()

# Split the dataset into separate files, one for each contract.
groups = tdf.group_by('address', maintain_order=True)
for name, data in groups:
    contract_address = name[0]
    contract_id = contract_mapping[contract_address]
    data.write_ndjson(f'{OUTPUT_DIR}/contract_{contract_id}.json')