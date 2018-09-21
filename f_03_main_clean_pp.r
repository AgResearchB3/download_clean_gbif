f_03_main_clean_pp <- function(one_sp_pp) {

	load(paste0(gbif_read_dir, "/", one_sp_pp)) # should be 'pp'

	#---------------------------------------------------------
	# If >10 duplicate records, reduce to 10
	# Maybe tidy this & convert to function?
	#---------------------------------------------------------

	pp$duplicate_check <- paste(pp$gbif_lon, # make new var to help check for duplicates
															pp$gbif_lat, 
															pp$country, 
															pp$countryCode)

	dups <- pp[duplicated(pp$duplicate_check), ]

	# If some records are duplicated more than 10x
	if (length(table(pp$duplicate_check)[table(pp$duplicate_check) > 10]) > 0) {

		no_dups <- pp[!duplicated(pp$duplicate_check), ] # keep unique records

		dups_to_keep <- # keep duplicates if there are <=10 duplicates of a record
			dups %>%
				group_by(duplicate_check) %>% 
				mutate(dup_num = length(duplicate_check)) %>%
				filter(dup_num <= 10) 
		dups_to_keep <- as.data.frame(dups_to_keep)
		dups_to_keep$dup_num <- NULL

		dups_subsampled <- # when there are >10 duplicates of a record, keep just 10
			dups %>%
				group_by(duplicate_check) %>% 
				mutate(dup_num = length(duplicate_check)) %>%
				filter(dup_num > 10) %>%
				sample_n(10)
		dups_subsampled <- as.data.frame(dups_subsampled)
		dups_subsampled$dup_num <- NULL

	pp <- rbind(no_dups, dups_to_keep, dups_subsampled)
	pp$duplicate_check <- NULL
	}

	#---------------------------------------------------------
	# Join each GBIF point to its corresponding country in the world SF
	#---------------------------------------------------------
	pts_ctry <- f_03A_JoinGbifPpsToWldSfCtryData(pp)

	#---------------------------------------------------------
	# Select the GBIF columns that contain country data, bind them with the SF 
	# country data, & convert factors to chr to make comparing columns easier in 
	# 'f_03C...'
	#---------------------------------------------------------
	gbif_ctry <- f_03B_SelectGbifColsWithCtryDat(pp)

	gb_sf_ctrys <- cbind(gbif_ctry, pts_ctry)

	gb_sf_ctrys <- 
		gb_sf_ctrys %>% 
		mutate_if(is.factor, as.character)

	#---------------------------------------------------------
	# For each point, compare the GBIF country to the SF country data, 
	# & ID those that differ by assigning a value to a var called chk
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
	# Measure distance between each point & its GBIF country border. 
	# Only check records that are > max_m_to_border
	#---------------------------------------------------------
	if (nrow(gb_to_chk) > 0) { 
		gb_to_chk <- f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder(gb_to_chk) 
		# Don't use 'dplyr::filter', which drops meters == NA
		gb_to_chk <- gb_to_chk[gb_to_chk$meters > max_m_to_border, ]
	} # end if 

	#---------------------------------------------------------
	# Delete suspect records from GBIF
	#---------------------------------------------------------
	if (nrow(gb_to_chk) > 0) { 

		show_dat <- T
		# Look at the GBIF records to be deleted
		if (show_dat) {
			show_vars <- c('country', 'iso2', 'meters', 'chk')
			show_cols <- sort(unlist(sapply(show_vars, 
															 function(x) grep(x, names(gb_to_chk), 
															 ignore.case = T)), 
												recursive = F,
												use.names = F))
			head(gb_to_chk[ , show_cols], n = 20)
		} # end if show
		
		gb_to_chk <- filter(gb_to_chk, !is.na(chk))

		# Delete the suspect records from the main data
		nrow(pp)
		pp <- pp[-as.integer(gb_to_chk$chk), ]
    nrow(pp)

	} # end if 

	#---------------------------------------------------------
	# Write cleaned records to RData
	#---------------------------------------------------------
	save(pp, file = paste0(gbif_write_dir, "/", one_sp_pp))

	message(paste('Saved', one_sp_pp, 'with records =', nrow(pp)))

	flush.console()

} # end function
