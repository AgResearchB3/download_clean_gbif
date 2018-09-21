f_02B_get_index_of_lon_column <- function(gbif_data) {

	# ^ & $ around a string means exact match
	lon_names <- c('^gbif_lon$', '^decimallongitude$', '^decimalLongitude$', '^longitude$', '^lon$')

	# return index of the first matching column name, or return NA if no match
	lon_index <- unlist(sapply(lon_names, function(x) grep(x, names(gbif_data))))[1]

	if (is.na(lon_index)) {
		warning(paste('Cannot find longitude data for', gbif_data$species[1])) 
	} 

# This doesn't work because class = "tbl_df", "tbl", "data.frame", rather than numeric
#	if (!is.na(lon_index)) {
#		if(!is.numeric(pp[, lon_index])) {
#			warning(paste('Longitude column for', gbif_data$species[1], 'is not numeric')) 
#		}
#	}

	return(lon_index)

}
