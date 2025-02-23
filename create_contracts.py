#
#   This script reads the original ERC-1155 transfer data sets (see https://zenodo.org/records/XXXXXX) 
#   and computes the top 100 contracts by number of raised transfers.
#
#   All transfers related to minting and burning operations (as well as self-transfers) are ignored.
#
#   OUTPUT:
#   - 100 CSV files, each describing all valid transfers related to a contract. Each row includes:
#       - block_id: identifier of block where the transfer occurred.
#       - contract_id: numeric identifier of contract (equal for all rows).
#       - from_id: identifier of sender.
#       - to_id: identifier of receiver.
#       - token_id: identifier of token being transferred.
#       - amount: quantity of tokens involved in the transfer.
#   - 1 CSV file with the contract ranking. Each row includes:
#       - rank: position of contract in the ranking (i.e., integer in [0, 99]);
#       - contract_id: numeric identifier of contract in the original dataset;
#       - address: Ethereum address of the contract;
#       - num_transfer: number of valid transfers produced by the contract.
#
#   Author: Matteo Loporchio
#

import pandas as pd

contracts_file = 'data/erc1155_contracts.csv'
transfers_file = 'data/erc1155_transfers.csv'
output_folder = 'results/contracts'

# Read the transfers data set.
t = pd.read_csv(transfers_file, 
                header=None, 
                names=['event_id','block_id','contract_id','event_type','operator_id','from_id','to_id','token_id','amount'], 
                low_memory=False)
# Read the contracts data set.
c = pd.read_csv(contracts_file, header=None, names=['address', 'contract_id'])

# Remove all non-standard transfers.
tf = t[(t.from_id != -1) & (t.to_id != -1) & (t.token_id != '-1') & (t.amount != '-1')]

# Remove all transfers originating from the 0x0 address (i.e., mint) and those directed to 0x0 (i.e., burn).
# Filter also all self-transfers (i.e., those where sender and receiver coincide).
tz = tf[(tf.from_id != 0) & (tf.to_id != 0) & (tf.from_id != tf.to_id)]

# Compute the contract ranking based on the number of raised transfers.
ranking = pd.DataFrame({'num_transfer': tz.groupby('contract_id').size().sort_values(ascending=False)}).reset_index()

# Select all events produced by the top 100 contracts.
top_ids = ranking.head(100).contract_id.values
fh = open(f'{output_folder}/ranking.csv', 'w')
fh.write('rank,contract_id,address,num_transfer\n')
for i in range(0, len(top_ids)):
    current_id = top_ids[i]
    current_address = c[c.contract_id == current_id].address.values[0]
    current_transfers = tz[tz.contract_id == current_id]
    current_transfers = current_transfers[['block_id', 'contract_id', 'from_id', 'to_id', 'token_id', 'amount']]
    current_transfers.to_csv(f'{output_folder}/contract_{i}.csv', header=False, index=False)
    fh.write(f'{i},{current_id},{current_address},{len(current_transfers)}\n')
fh.close()