fScreenVarsForVals <- function(object, var_name, val_text) 

# Screen a variable for particular values- eg, pp <- fScreenVarsForVals('pp', 'issue', 'ZERO_COORDINATE|COUNTRY_MISMATCH|COUNTRY_COORDINATE_MISMATCH')

{

	# Get column number of variable
	var_col_num <- grep(var_name, names(object), ignore.case = TRUE)

  # Warn if > 1 column contains var_name
	if (length(var_col_num) > 1) message(paste('Warning: >1 variable chosen for', var_name))

	# Change column name to var_name
	if (length(var_col_num) == 1) names(object)[var_col_num] <- var_name

	# Special case for 'coordinateUncertaintyInMeters' - uses coord_unc not val_text
	if (length(var_col_num) == 1 & var_name == 'coordinateUncertaintyInMeters') {
		del_rows <- which(object$coordinateUncertaintyInMeters > coord_unc)
		if (length(del_rows) > 0) object <- object[-del_rows, ]
	}

	# Otherwise omit records that contain val_text
	if (length(var_col_num) == 1 & var_name != 'coordinateUncertaintyInMeters') {
		del_rows <- which(grepl(val_text, object[ , var_col_num], ignore.case = T))
		if (length(del_rows) > 0) object <- object[-del_rows, ]
	}

	return(object)

} # end fScreenVarsForVals

