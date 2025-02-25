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
#   A CSV file where each row has the following fields:
#   - block_id: height of the block;
#   - num_active: number of active tokens up to block_id;
#
#   PRINT:
#   The number of transfers read from the input file.
#
#   Author: Matteo Loporchio
#

TRANSFERS_FILE = 'data/erc1155_transfers.csv'
OUTPUT_FILE = 'results/active_tokens.csv'

f1 = open(TRANSFERS_FILE, 'r')
f2 = open(OUTPUT_FILE, 'w')

pair_set = set()
block_map = dict()
count = 0

while True:
    line = f1.readline()
    if not line:
        break
    line = line.strip()
    parts = line.split(',')
    block_id = int(parts[1])
    contract_id = int(parts[2])
    from_id = int(parts[5])
    to_id = int(parts[6])
    token_id = int(parts[7])
    amount = int(parts[8])
    
    if (not ((from_id != -1) and (to_id != -1) and (token_id != '-1') and (amount != '-1'))):
        continue

    pair_set.add((contract_id, token_id))
    block_map[block_id] = len(pair_set)
    count += 1

for k, v in block_map.items():
    f2.write(f'{k},{v}\n')

f1.close()
f2.close()

print(f'Lines read: {count}')