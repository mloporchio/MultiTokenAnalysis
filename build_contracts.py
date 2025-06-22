"""

Author: Matteo Loporchio
"""
import polars as pl
import sys
import utils

TRANSFERS_FILE = sys.argv[1]
OUTPUT_DIR = sys.argv[2]
NULL_ADDRESS = "0x0000000000000000000000000000000000000000"

# Read the transfers dataset and remove all non-standard transfer events.
df = pl.read_parquet(TRANSFERS_FILE)
tdf = utils.filter_transfers(df)
tdf = tdf.explode(['token_ids', 'amounts'])

# Remove all transfers originating from the 0x0 address (i.e., mint) and those directed to 0x0 (i.e., burn).
# Filter also all self-transfers (i.e., those where sender and receiver coincide).
tdf = tdf.filter((pl.col('from') != NULL_ADDRESS) & (pl.col('to') != NULL_ADDRESS) & (pl.col('from') != pl.col('to')))

# Compute the contract ranking based on the number of raised transfers.
ranking = tdf.group_by('address').len().sort(by='len', descending=True).head(100)

fh = open(f'{OUTPUT_DIR}/ranking.tsv', 'w')
fh.write('rank\taddress\tnum_transfer\n')
id = 0
for row in ranking.iter_rows(named=True):
    current_contract = row['address']
    current_transfers = tdf.filter(pl.col('address') == current_contract)
    current_transfers.write_ndjson(f'{OUTPUT_DIR}/contract_{id}.json')
    fh.write(f'{id}\t{current_contract}\t{len(current_transfers)}\n')
    id += 1
fh.close()