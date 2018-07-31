fDeleteAllEmptyColumnsInDf <- function(my_df) {
## delete empty columns in dataframe
	all_na_cols <- apply(my_df, 2, function(x) all(is.na(x)))
	all_na_cols <- names(all_na_cols[all_na_cols == TRUE])
	cols_to_del <- which(names(my_df) %in% all_na_cols)
	if (length(cols_to_del) > 0) my_df <- my_df[ , -cols_to_del]
	return(my_df)
}

