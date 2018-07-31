# 18-May-2018, updated 23_May-2018: Any NZ records are retained in this script. They are excluded in '07_get_nz_projections.r'
# The line below is written by C.P, don't know what it refers to. Mariona, 30/05/18

#---------------------------------------------------------
# Read world SF & get vector of GBIF files to process.
#---------------------------------------------------------

# Read world countries RData SF

load('world_countries_wgs84.RData')

pp_to_process <- dir(gbif_read_cleaned_dir, pattern = ".RData") 
n_pp_files <- length(pp_to_process); n_pp_files

#---------------------------------------------------------
# Start file-by-file processing
#---------------------------------------------------------
i<-323

for (i in 322: n_pp_files) {

	# Get the file name to read
  one_sp_pp <- paste(gbif_read_cleaned_dir, pp_to_process[i], sep = '/')

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

#if (i>1) {
	#keep_me <- ls()[grep('f_03*', ls())]
	#keep_me <- c(keep_me, 'max_m_to_border', 'can', 'crs_geo', 'fDeleteAllEmptyColumnsInDf', 'fPlotBaseMapOfPts', 'func_dir', 'gbif_read_dir', 'gbif_write_dir', 'i', 'n_pp_files', 'pp_to_process', 'wld')
	#rm(list = ls()[!ls() %in% keep_me])
	#rm(list = ls()[!ls() %in% keep_me])
	

# Identify longitude and latitude columns
	#one_sp_pp <- paste0(gbif_read_dir, "/", pp_to_process[i])
	
	#if (file.exists(one_sp_pp) {
   #   load(one_sp_pp)
  #  } else {
 #     message(paste0("\nNo file '", one_sp_pp, "' on disc"))
#  }
	lon_col <- grep('lon', names(pp), ignore.case = TRUE)
	lat_col <- grep('lat', names(pp), ignore.case = TRUE)
	
	if (length(lon_col) == 0 | length(lat_col) == 0) {
	
		message(paste(pp_to_process[i],'has no proper coordinate data'))
	    NoCoordinatesCount = NoCoordinatesCount+1
	} else { 
		#}
		
	#---------------------------------------------------------
	# Read one GBIF file & rename it
	#---------------------------------------------------------
	

	#load(one_sp_pp)

	# Rename pps/pp to gbif & delete pps
	if (exists('pp')) {
		gbif <- pp
		rm(pp)
	}
	if (exists('pps')) {
		gbif <- pps
		rm(pps)
	}

	#---------------------------------------------------------
	# Join each GBIF point to its corresponding country in the world SF
	#---------------------------------------------------------
	pts_ctry <- f_03A_JoinGbifPpsToWldSfCtryData(gbif)

	#---------------------------------------------------------
	# Select the GBIF columns that contain country data, bind them with the SF country data, & convert factors to chr to make comparing columns easier in 'f_03C...'
	#---------------------------------------------------------
	gbif_ctry <- f_03B_SelectGbifColsWithCtryDat(gbif)

	gb_sf_ctrys <- cbind(gbif_ctry, pts_ctry)

	gb_sf_ctrys <- 
		gb_sf_ctrys %>% 
		mutate_if(is.factor, as.character)

	#---------------------------------------------------------
	# For each point, compare the GBIF country to the SF country data, & ID those that differ by assigning a value to a var called chk
	#---------------------------------------------------------
	gb_sf_ctrys <- f_03C_IdRecsWithCtryDatThatDifferBetweenGbifAndWldSf(gb_sf_ctrys)

	#---------------------------------------------------------
	# Subset gb_sf_ctrys to those that need to be checked
	#---------------------------------------------------------
	gb_to_chk <- filter(gb_sf_ctrys, !is.na(chk))

	#---------------------------------------------------------
	# Accept certain country name/code discrepancies between SF & GBIF
	#---------------------------------------------------------
	if (nrow(gb_to_chk) > 0) { 
		gb_to_chk <- f_03D_fAcceptSomeCountryDiscrepanciesBetweenShapeAndGbif(gb_to_chk)
	}

	#---------------------------------------------------------
	# Measure distance between each point & its GBIF country border. Only check records that are > max_m_to_border
	#---------------------------------------------------------
#		fPlotBaseMapOfPts(gb_to_chk$gbif_lon, gb_to_chk$gbif_lat, 'Points to check')
	if (nrow(gb_to_chk) > 0) { 
		gb_to_chk <- f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder(gb_to_chk) 

		# Don't use 'dplyr::filter', which drops meters == NA
		gb_to_chk <- gb_to_chk[gb_to_chk$meters > max_m_to_border, ]
		} # end if 

	#---------------------------------------------------------
	# Delete suspect records from GBIF
	#---------------------------------------------------------
	if (nrow(gb_to_chk) > 0) { 

		show_dat <- F
		# Look at the GBIF records to be deleted
		if (show_dat) {
			show_vars <- c('country', 'iso2', 'meters', 'chk')
			show_cols <- sort(unlist(sapply(show_vars, 
															 function(x) grep(x, names(gb_to_chk), 
															 ignore.case = T)), 
												recursive = F,
												use.names = F))
			gb_to_chk[ , show_cols]
		} # end if show

		# Delete the suspect records from the main data
		nrow(gbif)
		gb_to_chk <- gb_to_chk[-c(which(is.na(gb_to_chk$meters))),] # Check & delete the NA we introduced in f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder to avoid error in next line
		gbif <- gbif[-as.integer(gb_to_chk$chk), ]
    nrow(gbif)

	} # end if 

	#---------------------------------------------------------
	# Write cleaned records to RData
	#---------------------------------------------------------
	save(gbif, file = paste0(gbif_write_country_cleaned_dir, '/', pp_to_process[i]))

	message(paste0(i, ' of ', n_pp_files, ': ', paste(gbif_write_dir, pp_to_process[i], sep = '/')))

	flush.console()
}
} # end for loop

#dir(gbif_write_dir, pattern = '.RData')
 