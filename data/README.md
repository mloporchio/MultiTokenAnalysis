# data

This directory contains the data used for reproducing the experiments presented in the paper.

Due to space constraints, the actual data files are not included. 
However, they can be downloaded from the following Zenodo repository:

https://doi.org/10.5281/zenodo.14901527

The dataset consists of the `erc1155_transfers.json.gz` file, compressed using the GZIP utility.
To run the experiments, please make sure to download and extract it within this directory, 
so that the file `erc1155_transfers.json` is available.

The current directory also includes a TSV file, named `erc20-721_stats.tsv.xz` compressed using
the XZ utility (https://tukaani.org/xz). This file records the number of ERC-20 and ERC-721 transfer
events triggered for each block, as such information is used for comparison with the ERC-1155
standard within the paper. To use this file in the analysis, please make sure to decompress it using the XZ utility, 
so that the file `erc20-721_stats.tsv` is available.
