#
#   This script counts the number of active contracts up to a certain block height.
#   For a given block height h, a contract C is considered active if and only if
#   there exists at least one transfer produced by C in a block with height h' <= h.
#   
#   INPUT:
#   The dataset of ERC-1155 transfers.
#
#   OUTPUT:
#   A CSV file where each row has the following fields:
#   - block_id: height of the block;
#   - num_active: number of active contracts up to block_id;
#
#   PRINT:
#   The number of transfers read from the input file.
#
#   Author: Matteo Loporchio
#

TRANSFERS_FILE = 'data/erc1155_transfers.csv'
OUTPUT_FILE = 'results/active_contracts.csv'

f1 = open(TRANSFERS_FILE, 'r')
f2 = open(OUTPUT_FILE, 'w')

contractIds = set()
blockMap = dict()
count = 0

while True:
    line = f1.readline()
    if not line:
        break
    line = line.strip()
    parts = line.split(',')
    blockId = int(parts[1])
    contractId = int(parts[2])
    fromId = int(parts[5])
    toId = int(parts[6])
    tokenId = int(parts[7])
    value = int(parts[8])
    
    # This ignores all invalid transfers (i.e., those that do not)
    if (not ((fromId != -1) and (toId != -1) and (tokenId != '-1') and (value != '-1'))):
        continue

    contractIds.add(contractId)
    blockMap[blockId] = len(contractIds)
    count += 1


for k, v in blockMap.items():
    f2.write(f'{k},{v}\n')

f1.close()
f2.close()

print(f'Lines read: {count}')