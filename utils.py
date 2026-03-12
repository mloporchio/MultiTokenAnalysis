"""
Author: Matteo Loporchio
"""

import polars as pl
import matplotlib.pyplot as plt

def filter_transfers(df):
    return (df.filter(~(pl.col('operator').is_null() | pl.col('from').is_null() | pl.col('to').is_null()))
            .filter(~(pl.col('token_ids').is_null()) & (pl.col('token_ids').list.len() > 0))
            .filter(~(pl.col('amounts').is_null()) & (pl.col('amounts').list.len() > 0))
            .filter(pl.col('token_ids').list.len() == pl.col('amounts').list.len()))

def set_font_size(ax, font_size):
    for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] + ax.get_xticklabels() + ax.get_yticklabels()):
        item.set_fontsize(font_size)