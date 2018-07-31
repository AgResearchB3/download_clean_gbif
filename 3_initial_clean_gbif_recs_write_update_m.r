#----------------------------------------------------------------------------------
# CBP, April 2018. Read GBIF data, omit incorrect/uncertain records, write cleaned data to new file in different directory
# Mariona Roige, 28/05/2018. Tweaking the script to use it with my data. 
#----------------------------------------------------------------------------------

NoCoordinatesCount = 0

if (!dir.exists(gbif_write_dir)) dir.create(gbif_write_dir)

pp_to_process <- dir(gbif_read_dir, pattern = '.RData') 

n_pp_files <- length(pp_to_process); n_pp_files

#--------------------------------------------
# In a loop, read & process one GBIF RData file at a time
#--------------------------------------------


for (i in 1: n_pp_files) {


	# Get the file name to read
  one_sp_pp <- paste(gbif_read_dir, pp_to_process[i], sep = '/')

	# Read the file
	if (file.exists(one_sp_pp)) {
			load(one_sp_pp)
		} else {
			message(paste0("\nNo file '", one_sp_pp, "' on disc"))
	}

	#-------------------------------
	# Rename pps to pp & delete pps
	#-------------------------------

	if (exists('pps')) pp <- pps
	if (exists('pps')) rm(pps)
	message(paste('Records in', one_sp_pp, '=', nrow(pp)))

	#-------------------------------
	# Delete empty columns
	#-------------------------------

	cols1 <- ncol(pp)
	pp <- fDeleteAllEmptyColumnsInDf(pp)
	message(paste('Empty columns deleted =', cols1 - ncol(pp)))

	#-------------------------------
	# Omit records without coordinates and warn about species without coordinates
	#-------------------------------

	# Identify longitude and latitude columns
	lon_col <- grep('lon', names(pp), ignore.case = TRUE)
	lat_col <- grep('lat', names(pp), ignore.case = TRUE)
	
	if (length(lon_col) == 0 | length(lat_col) == 0) {
	
		message(paste(pp_to_process[i],'has no proper coordinate data'))
	    NoCoordinatesCount = NoCoordinatesCount+1
	} else { 
				if (length(lon_col) > 1) {
				
				message('Warning: >1 variable chosen for longitude')} 

				# Identify latitude column
				lat_col <- grep('lat', names(pp), ignore.case = TRUE)
				nom_col <- grep('nomenclatural', names(pp), ignore.case = TRUE)
				lat_col <- lat_col[!lat_col %in% nom_col]
				if (length(lat_col) > 1) message(paste('Warning: >1 variable chosen for latitude'))

				# Replace unknown longitude & latitude column names with known names
				names(pp)[lon_col] <- 'lon'
				names(pp)[lat_col] <- 'lat'

				# Omit records without coordinates
				rows1 <- nrow(pp)
				pp <- fOmitRecordsWithNaInSpecifiedCols(pp, c('lon', 'lat'))
				message(paste('Records without coordinates omitted =', rows1 - nrow(pp)))
				rm(lon_col, lat_col, nom_col)
									}	
		#-------------------------------
		# Screen coordinate uncertainty 
		#-------------------------------
		# I don't run this part cos later on (next script) there's a test on whether the coordinates fall into 
		# the right country
		# rows1 <- nrow(pp)
		# pp <- fScreenVarsForVals('coordinateUncertaintyInMeters', 'a_silly_old_fart')
		# message(paste('Records with high xy uncertainty deleted =', rows1 - nrow(pp)))

	
	
	#-------------------------------
	# Screen 'issues'
	#-------------------------------
	rows1 <- nrow(pp)
	pp <- fScreenVarsForVals('issue', 'ZERO_COORDINATE|COUNTRY_MISMATCH|COUNTRY_COORDINATE_MISMATCH')
	message(paste('Records with bad issues deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Screen 'basisofrecord'
	#-------------------------------

	rows1 <- nrow(pp)
	pp <- fScreenVarsForVals('basisofrecord', 'MACHINE_OBSERVATION|FOSSIL SPECIMEN')
	message(paste('Records with bad basis of record deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Screen concatenated location
	#-------------------------------

#	rows1 <- nrow(pp)
#	pp <- fScreenVarsForVals('cloc', 'cultivated')
#	message(paste('Records with bad cloc deleted =', rows1 - nrow(pp)))

	#-------------------------------
	# Save file
	#-------------------------------

	if (nrow(pp) > 0) {
		save(pp, file = paste(gbif_write_dir, pp_to_process[i], sep = '/'))
		message(paste(pp_to_process[i], 'cleaned has', nrow(pp), 'records\n'))
		} else {
		message(paste(pp_to_process[i], 'cleaned has zero records\n'))
	}

	flush.console()

} # end for loop

print(paste('The number of species with no proper coordinates is', NoCoordinatesCount))


dir(gbif_write_dir, pattern = '.RData')
