#
#   This Python script computes the coverage (i.e., percentage of graph nodes in the largest component)
#   for both weakly and strongly connected components of an ERC-1155 Token Transfer Graph.
#
#   INPUT:
#   The script takes as input the following arguments:
#     - path of the (node -> component_id) mapping file.
#       Note that this file is produced by the `graph_connectivity` executable when analyzing the graph.
#
#   PRINT:
#   The script prints to stdout the following values separated by a TAB character:
#     - coverage of the weakly connected component;
#     - coverage of the strongly connected component.
#
#   Author: Matteo Loporchio
#

import polars as pl
import sys

INPUT_FILE = sys.argv[1]

df = pl.read_csv(INPUT_FILE, separator='\t')
coverage_wcc = df['wcc_id'].value_counts().sort(by='count', descending=True)['count'][0] / len(df)
coverage_scc = df['scc_id'].value_counts().sort(by='count', descending=True)['count'][0] / len(df)

print(f"{coverage_wcc:.6f}\t{coverage_scc:.6f}")