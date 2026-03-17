#
#   This script counts the number of active contracts up to a certain block height.
#   For a given block height h, a contract C is considered active if and only if
#   there exists at least one transfer produced by C in a block with height h' <= h.
#   The script counts active contracts based on the centralization index of the
#   corresponding networks. Indeed, networks are classified as in-stars, out-stars, 
#   in-out stars, and non-star networks based on their in-degree and out-degree 
#   centralization indices:
#   - in-stars have in-degree (resp. out-degree) centralization index == 1 (resp. != 1).
#   - out-stars have in-degree (resp. out-degree) centralization index != 1 (resp. == 1).
#   - in-out stars have both centralization indices == 1.
#   - non-star graphs have both indices != 1.
#   
#   INPUT:
#   - The dataset of ERC-1155 transfers.
#   - The TSV file containing information about centralization indices of all networks.
#
#   OUTPUT:
#   A TSV file where each row has the following fields:
#   - block_id: height of the block;
#   - in_stars: number of active in-star networks up to block_id;
#   - out_stars: number of active out-star networks up to block_id;
#   - in_out_stars: number of active in-out star graphs up to block_id;
#   - not_stars: number of active non-star graphs up to block_id.
#
#   PRINT:
#   The number of transfers read from the input file is printed to stdout.
#
#   Author: Matteo Loporchio
#

import polars as pl
import utils

TRANSFERS_FILE = 'data/erc1155_transfers.parquet'
CENTRALIZATION_FILE = 'results/graph_centralization.tsv'
OUTPUT_FILE = 'results/active_stars.tsv'
NULL_ADDRESS = "0x0000000000000000000000000000000000000000"

# Read the ERC-1155 transfer dataset.
tdf = pl.read_parquet(TRANSFERS_FILE)
tdf = utils.filter_transfers(tdf)
tdf = tdf.filter((pl.col('from') != NULL_ADDRESS) & (pl.col('to') != NULL_ADDRESS) & (pl.col('from') != pl.col('to')))

# Read the file including centralization information and partition the graphs into four categories:
# in-stars, out-stars, in-out-stars and non-star networks.
cdf = pl.read_csv(CENTRALIZATION_FILE, separator='\t')
in_contracts = set(cdf.filter((pl.col("in_cent") == 1) & (pl.col("out_cent") != 1))['address'])
out_contracts = set(cdf.filter((pl.col("in_cent") != 1) & (pl.col("out_cent") == 1))['address'])
in_out_contracts = set(cdf.filter((pl.col("in_cent") == 1) & (pl.col("out_cent") == 1))['address'])
not_contracts = set(cdf.filter((pl.col("in_cent") != 1) & (pl.col("out_cent") != 1))['address'])

in_stars = set()
out_stars = set()
in_out_stars = set()
not_stars = set()
in_block_map = dict()
out_block_map = dict()
in_out_block_map = dict()
not_block_map = dict()
count = 0

for row in tdf.iter_rows():
    contract = row[0]
    block_id = row[4]
    if contract in in_contracts:
        in_stars.add(contract)
    if contract in out_contracts:
        out_stars.add(contract)
    if contract in in_out_contracts:
        in_out_stars.add(contract)
    if contract in not_contracts:
        not_stars.add(contract)
    in_block_map[block_id] = len(in_stars)
    out_block_map[block_id] = len(out_stars)
    in_out_block_map[block_id] = len(in_out_stars)
    not_block_map[block_id] = len(not_stars)
    count += 1

fh = open(OUTPUT_FILE, 'w')
fh.write('block_number\tin_stars\tout_stars\tin_out_stars\tnot_stars\n')
for k, v in in_block_map.items():
    num_in = v
    num_out = out_block_map[k]
    num_in_out = in_out_block_map[k]
    num_not = not_block_map[k]
    fh.write(f'{k}\t{num_in}\t{num_out}\t{num_in_out}\t{num_not}\n')
fh.close()

print(f'Rows processed: {count}')