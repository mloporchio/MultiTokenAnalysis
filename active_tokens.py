#
#   This script counts the number of active tokens up to a certain block height.
#   For a given block height h, a token T of a contract C is considered active 
#   if and only if there exists at least one transfer produced by C for token T
#   included in a block with height h' <= h.
#   
#   INPUT:
#   The dataset of ERC-1155 transfers.
#
#   OUTPUT:
#   A TSV file where each row has the following fields:
#   - block_id: height of the block;
#   - num_active_tokens: number of active tokens up to block_id;
#
#   PRINT:
#   The number of transfers read from the input file is printed to stdout.
#
#   Author: Matteo Loporchio
#

import polars as pl

TRANSFERS_FILE = 'data/erc1155_transfers.parquet'
OUTPUT_FILE = 'results/active_tokens.tsv'

def filter_transfers(df):
    return (df.filter(~(pl.col('operator').is_null() | pl.col('from').is_null() | pl.col('to').is_null()))
            .filter(~(pl.col('token_ids').is_null()) & (pl.col('token_ids').list.len() > 0))
            .filter(~(pl.col('amounts').is_null()) & (pl.col('amounts').list.len() > 0))
            .filter(pl.col('token_ids').list.len() == pl.col('amounts').list.len()))

pair_set = set()
block_map = dict()
count = 0

df = pl.read_parquet(TRANSFERS_FILE)
df = filter_transfers(df)

for row in df.iter_rows():
    contract = row[0]
    block_id = row[4]
    token_ids = row[10]
    for token_id in token_ids:
        pair_set.add((contract, token_id))
    block_map[block_id] = len(pair_set)
    count += 1

fh = open(OUTPUT_FILE, 'w')
fh.write('block_id\tnum_active_tokens\n')
for k, v in block_map.items():
    fh.write(f'{k}\t{v}\n')
fh.close()

print(f'Rows processed: {count}')