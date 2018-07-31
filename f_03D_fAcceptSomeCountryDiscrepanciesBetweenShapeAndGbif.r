f_03D_fAcceptSomeCountryDiscrepanciesBetweenShapeAndGbif <- function(recs_to_chk) {
# CBP 20-May-2018: Eliminate some acceptable differences in country names/codes between GIS shapefile & GBIF records. The 'if sum %in%' condition checks both variable names are present in the data before screening them.

	# Finland & Aland Islands; South Africa & Lesotho; Ireland & UK
	if (sum(c('gbif_countrycode', 'ISO2') %in% names(recs_to_chk)) == 2) {
		recs_to_chk <- filter(recs_to_chk, !(gbif_countrycode == 'FI' & ISO2 == 'AX')) 
		recs_to_chk <- filter(recs_to_chk, !(gbif_countrycode == 'ZA' & ISO2 == 'LS')) 
		recs_to_chk <- filter(recs_to_chk, !(gbif_countrycode == 'IE' & ISO2 == 'GB'))
	}

	# Iran & Iran (Islamic Republic of); Mongolia & China 
	if (sum(c('gbif_country', 'NAME') %in% names(recs_to_chk)) == 2) {
		recs_to_chk <- filter(recs_to_chk, !(gbif_country == 'Iran' & NAME == 'Iran (Islamic Republic of)')) 
		recs_to_chk <- filter(recs_to_chk, !(gbif_country == 'Mongolia' & NAME == 'China')) 
	}

	# UK & Isle of Man; France & Monaco; Finland & Aland Islands
	if (sum(c('gbif_ISO2', 'ISO2') %in% names(recs_to_chk)) == 2) {
		recs_to_chk <- filter(recs_to_chk, !(gbif_ISO2 == 'GB' & ISO2 == 'IM')) 
		recs_to_chk <- filter(recs_to_chk, !(gbif_ISO2 == 'FR' & ISO2 == 'MC')) 
		recs_to_chk <- filter(recs_to_chk, !(gbif_ISO2 == 'FI' & ISO2 == 'AX')) 
	}

	# UK & Isle of Man
	if (sum(c('gbif_country', 'COUNTRY') %in% names(recs_to_chk)) == 2) {
		recs_to_chk <- filter(recs_to_chk, !(gbif_country == 'United Kingdom' & COUNTRY == 'Isle of Man')) 
	}

# Palestine, State Of & Palestine; Tanzania, United Republic of & United Republic of Tanzania
	if (sum(c('gbif_fullCountry', 'NAME') %in% names(recs_to_chk)) == 2) {
		recs_to_chk <- filter(recs_to_chk, !(gbif_fullCountry == 'Palestine, State Of' & NAME == 'Palestine')) 
		recs_to_chk <- filter(recs_to_chk, !(gbif_fullCountry == 'Tanzania, United Republic of' & NAME == 'United Republic of Tanzania')) 
	}

	return(recs_to_chk)

} # end function