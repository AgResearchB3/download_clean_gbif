f_03C_IdRecsWithCtryDatThatDifferBetweenGbifAndWldSf <- function(ctry_recs) {

#---------------------------------------------------------
# Check for discrepancies between the country details of the GBIF records & those of the world shapefile.
#---------------------------------------------------------
#ctry_recs <- gb_sf_ctrys
#glimpse(ctry_recs)
#View(ctry_recs)
#head(ctry_recs)

# To start, assign all records with an integer value for 'chk' (= row number)
ctry_recs$chk <- rownames(ctry_recs)

	# If gbif_country == sf_COUNTRY, then chk == NA
	#  ^ indicates string start & $ indicates end
	gb_col <- grep('^gbif_country$', names(ctry_recs), ignore.case = T) 
	sf_col <- grep('^COUNTRY$', names(ctry_recs), ignore.case = F)
	if (length(gb_col) == 1 & length(sf_col) == 1) {
		ctry_recs$chk[which(ctry_recs[gb_col] == ctry_recs[sf_col])] <- NA
		rm(gb_col, sf_col)
	}

	# If gbif_country == sf_NAME, then chk == NA
	gb_col <- grep('^gbif_country$', names(ctry_recs), ignore.case = T) 
	sf_col <- grep('^NAME$', names(ctry_recs), ignore.case = F)
	if (length(gb_col) == 1 & length(sf_col) == 1) {
		ctry_recs$chk[which(ctry_recs[gb_col] == ctry_recs[sf_col])] <- NA
		rm(gb_col, sf_col)
	}

	# If gbif_fullCountry == sf_COUNTRY, then chk == NA
	gb_col <- grep('^gbif_fullCountry$', names(ctry_recs), ignore.case = T) 
	sf_col <- grep('^COUNTRY$', names(ctry_recs), ignore.case = F)
	if (length(gb_col) == 1 & length(sf_col) == 1) {
		ctry_recs$chk[which(ctry_recs[gb_col] == ctry_recs[sf_col])] <- NA
		rm(gb_col, sf_col)
	}

	# If gbif_ISO2 == sf_ISO2, then chk == NA
	gb_col <- grep('^gbif_ISO2$', names(ctry_recs), ignore.case = T) 
	sf_col <- grep('^ISO2$', names(ctry_recs), ignore.case = F)
	if (length(gb_col) == 1 & length(sf_col) == 1) {
		ctry_recs$chk[which(ctry_recs[gb_col] == ctry_recs[sf_col])] <- NA
		rm(gb_col, sf_col)
	}

	# If gbif_countrycode == sf_ISO2, then chk == NA
	gb_col <- grep('^gbif_countrycode$', names(ctry_recs), ignore.case = T) 
	sf_col <- grep('^ISO2$', names(ctry_recs), ignore.case = F)
	if (length(gb_col) == 1 & length(sf_col) == 1) {
		ctry_recs$chk[which(ctry_recs[gb_col] == ctry_recs[sf_col])] <- NA
		rm(gb_col, sf_col)
	}

#length(ctry_recs$chk[!is.na(ctry_recs$chk)])
#View(ctry_recs[!is.na(ctry_recs$chk), ])

	return(ctry_recs)
}	


