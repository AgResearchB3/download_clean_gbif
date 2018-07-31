fScreenVarsForVals <- function(var_name, val_text) {

	# Get column number of variable
	var_col_num <- grep(var_name, names(pp), ignore.case = TRUE)

  # Warn if > 1 column contains var_name
	if (length(var_col_num) > 1) message(paste('Warning: >1 variable chosen for', var_name))

	# Change column name to var_name
	if (length(var_col_num) == 1) names(pp)[var_col_num] <- var_name

	# Special case for 'coordinateUncertaintyInMeters' - uses coord_unc not val_text
	if (length(var_col_num) == 1 & var_name == 'coordinateUncertaintyInMeters') {
		del_rows <- which(pp$coordinateUncertaintyInMeters > coord_unc)
		if (length(del_rows) > 0) pp <- pp[-del_rows, ]
	}

	# Otherwise omit records that contain val_text
	if (length(var_col_num) == 1 & var_name != 'coordinateUncertaintyInMeters') {
		del_rows <- which(grepl(val_text, pp[ , var_col_num], ignore.case = T))
		if (length(del_rows) > 0) pp <- pp[-del_rows, ]
	}

	return(pp)

} # end fScreenVarsForVals

