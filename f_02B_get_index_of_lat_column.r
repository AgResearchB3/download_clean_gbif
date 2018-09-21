f_02B_get_index_of_lat_column <- function(gbif_data) {

	# ^ & $ around a string means exact match
	lat_names <- c('^gbif_lat$', '^decimallatitude$', '^decimalLatitude$', '^latitude$', '^lat$')

	# return index of the first matching column name, or return NA if no match
	lat_index <- unlist(sapply(lat_names, function(x) grep(x, names(gbif_data))))[1]

	if (is.na(lat_index)) {
		warning(paste('Cannot find latitude data for', gbif_data$species[1])) 
	}

# This doesn't work because class = "tbl_df", "tbl", "data.frame", rather than numeric
#	if (!is.na(lat_index)) {
#		if(!is.numeric(pp[, lat_index])) {
#			warning(paste('Latitude column for', gbif_data$species[1], 'is not numeric')) 
#		}
#	}

	return(lat_index)
}
