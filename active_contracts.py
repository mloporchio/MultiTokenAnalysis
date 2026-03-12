#
#   This script counts the number of active contracts up to a certain block height.
#   For a given block height h, a contract C is considered active if and only if
#   there exists at least one transfer produced by C in a block with height h' <= h.
#   
#   INPUT:
#   The dataset of ERC-1155 transfers.
#
#   OUTPUT:
#   A TSV file where each row has the following fields:
#   - block_id: height of the block;
#   - num_active_contracts: number of active contracts up to block_id;
#
#   PRINT:
#   The number of transfers read from the input file is printed to stdout.
#
#   Author: Matteo Loporchio
#

import polars as pl

TRANSFERS_FILE = 'data/erc1155_transfers.parquet'
OUTPUT_FILE = 'results/active_contracts.tsv'

def filter_transfers(df):
    return (df.filter(~(pl.col('operator').is_null() | pl.col('from').is_null() | pl.col('to').is_null()))
            .filter(~(pl.col('token_ids').is_null()) & (pl.col('token_ids').list.len() > 0))
            .filter(~(pl.col('amounts').is_null()) & (pl.col('amounts').list.len() > 0))
            .filter(pl.col('token_ids').list.len() == pl.col('amounts').list.len()))

df = pl.read_parquet(TRANSFERS_FILE)
df = filter_transfers(df)

contracts = set()
block_map = dict()
count = 0

for row in df.iter_rows():
    contract = row[0]
    block_id = row[4]
    contracts.add(contract)
    block_map[block_id] = len(contracts)
    count += 1

fh = open(OUTPUT_FILE, 'w')
fh.write('block_id\tnum_active_contracts\n')
for k, v in block_map.items():
    fh.write(f'{k}\t{v}\n')
fh.close()

print(f'Rows processed: {count}')