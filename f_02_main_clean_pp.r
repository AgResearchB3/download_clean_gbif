f_02_main_clean_pp <- function(one_sp_pp) {

#	one_sp_pp <- pp_to_process[1]

	load(paste(gbif_read_dir, one_sp_pp, sep = '/')) # should be 'pp'

	#-------------------------------
	# Rename pps to pp, delete pps & save pp back to original filename
	#-------------------------------
	if (exists('pps')) {
		pp <- pps
		rm(pps)
		save(pp, file = one_sp_pp)
		message(paste('Renamed pps to pp & saved to', one_sp_pp))
	}

	message(paste('\nRecords in', one_sp_pp, '=', nrow(pp)))

	#-------------------------------
	# Screen coordinate uncertainty 
	#-------------------------------
	rows1 <- nrow(pp)
	pp <- fScreenVarsForVals(pp, 'coordinateUncertaintyInMeters', 'exception_for_coord_unc')
	message(paste('Records with high xy uncertainty deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Screen 'issues'
	#-------------------------------
	rows1 <- nrow(pp)
	pp <- fScreenVarsForVals(pp, 'issue', 'ZERO_COORDINATE|COUNTRY_MISMATCH|COUNTRY_COORDINATE_MISMATCH')
	message(paste('Records with bad issues deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Screen 'basisofrecord'
	#-------------------------------
	rows1 <- nrow(pp)
	pp <- fScreenVarsForVals(pp, 'basisofrecord', 'MACHINE_OBSERVATION|FOSSIL SPECIMEN')
	message(paste('Records with bad basis of record deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Screen concatenated location
	#-------------------------------
	#	rows1 <- nrow(pp)
	#	pp <- fScreenVarsForVals(pp, 'cloc', 'cultivated')
	#	message(paste('Records with bad cloc deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Omit records without coordinates
	#-------------------------------
	# Identify the columns that contains lon & lat
	lon_col <- f_02B_get_index_of_lon_column(pp)
	lat_col <- f_02B_get_index_of_lat_column(pp)

	if (!is.na(lon_col) & !is.na(lat_col)) {
		# Replace unknown longitude & latitude column names with known names
		names(pp)[lon_col] <- 'gbif_lon' 
		names(pp)[lat_col] <- 'gbif_lat' 
		rows1 <- nrow(pp)
		# Omit records without coordinates
		pp <- fOmitRecordsWithNaInSpecifiedCols(pp, c('gbif_lon', 'gbif_lat')) 
		message(paste('Records without coordinates omitted =', rows1 - nrow(pp)))
	}

	#-------------------------------
	# Delete empty columns
	#-------------------------------
	cols1 <- ncol(pp)
	pp <- fDeleteAllEmptyColumnsInDf(pp)
	message(paste('Empty columns deleted =', cols1 - ncol(pp)))

	#-------------------------------
	# Save file if it has >0 records with coordinates
	#-------------------------------
	if (nrow(pp) > 0 & !is.na(lon_col) & !is.na(lat_col)) {
		save(pp, file = paste(gbif_write_dir, one_sp_pp, sep = '/'))
		message(paste('Saved', one_sp_pp, 'with records =', nrow(pp)))
		} else {
		message(paste(one_sp_pp, 'cleaned has 0 records with xy coordinates\nso was not saved to', gbif_write_dir, '\n'))
	}

	flush.console()

} # end function


