#
#   This script contains utility functions for processing the dataset and plotting results.
#
#   Author: Matteo Loporchio
#

import polars as pl
import matplotlib.pyplot as plt

def filter_transfers(df):
    """
    Filters the dataset of ERC-1155 transfers to include only valid transfers.
    The function filters out rows with null values in the operator, from, or to fields.
    """
    return (df.filter(~(pl.col('operator').is_null() | pl.col('from').is_null() | pl.col('to').is_null()))
            .filter(~(pl.col('token_ids').is_null()) & (pl.col('token_ids').list.len() > 0))
            .filter(~(pl.col('amounts').is_null()) & (pl.col('amounts').list.len() > 0))
            .filter(pl.col('token_ids').list.len() == pl.col('amounts').list.len()))

def set_font_size(ax, font_size):
    """
    Sets the font size for the title, axis labels, and tick labels of a Matplotlib plot.
    """
    for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] + ax.get_xticklabels() + ax.get_yticklabels()):
        item.set_fontsize(font_size)