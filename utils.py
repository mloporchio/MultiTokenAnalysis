import polars as pl

def filter_transfers(df):
    return (df.filter(~(pl.col('operator').is_null() | pl.col('from').is_null() | pl.col('to').is_null()))
            .filter(~(pl.col('token_ids').is_null()) & (pl.col('token_ids').list.len() > 0))
            .filter(~(pl.col('amounts').is_null()) & (pl.col('amounts').list.len() > 0))
            .filter(pl.col('token_ids').list.len() == pl.col('amounts').list.len()))

