import polars as pl
import utils

OUTPUT_FILE = "supply/supply.tsv"
TRANSFER_FILE = "data/erc1155_transfers.parquet"
NULL_ADDRESS = "0x0000000000000000000000000000000000000000"
count_map = dict()

df = pl.read_parquet(TRANSFER_FILE)
tdf = utils.filter_transfers(df)
tdf = tdf.explode(['token_ids', 'amounts'])
mdf = tdf.filter(((pl.col("from") == NULL_ADDRESS) | (pl.col("to") == NULL_ADDRESS)) & (pl.col("from") != pl.col("to")))

for row in mdf.iter_rows(named=True):
    address = row['address']
    token_id = int(row['token_ids'])
    amount = int(row['amounts'])
    from_addr = row['from']
    to_addr = row['to']
    k = address + ":" + str(token_id)
    if from_addr == NULL_ADDRESS:
        # Minting
        count_map[k] = count_map.get(k, 0) + amount
    elif to_addr == NULL_ADDRESS:
        # Burning
        count_map[k] = count_map.get(k, 0) - amount

with open(OUTPUT_FILE, "w") as fh:
    for k in count_map.keys():
        parts = k.split(":")
        supply = count_map[k]
        fh.write(f"{parts[0]}\t{parts[1]}\t{supply}\n")