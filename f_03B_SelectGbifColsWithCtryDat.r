f_03B_SelectGbifColsWithCtryDat <- function(gb_raw_dat) {

#---------------------------------------------------------
# Identify which GBIF data columns give country details for each presence point. The resulting vector of column indices, gbif_ctry_col, is used to subset all the gbif data into a new df called gbif_ctry.
#---------------------------------------------------------

	gbif_ctry_col <- grep('country', names(gb_raw_dat), ignore.case = TRUE)
	gbif_ctry_col <- c(gbif_ctry_col, grep('iso', names(gb_raw_dat), ignore.case = TRUE))
	gbif_ctry_col <- c(gbif_ctry_col, grep('cloc', names(gb_raw_dat), ignore.case = TRUE))

	not_col <- grep('publishing', names(gb_raw_dat), ignore.case = TRUE)
	not_col <- c(not_col, grep('basisof', names(gb_raw_dat), ignore.case = TRUE))

	gbif_ctry_col <- gbif_ctry_col[!gbif_ctry_col %in% not_col]

#---------------------------------------------------------
# Subset all the gbif data into a new df called gbif_ctry, which contains just the GBIF point coordinates & their GBIF country details. Precede the column names with gbif_ to distinguish them from world shapefile variables that are to be added later
#---------------------------------------------------------
	gbif_ctry_names <- names(gb_raw_dat)[gbif_ctry_col]

	gbif_ctry <- gb_raw_dat[ , c('gbif_lon', 'gbif_lat', gbif_ctry_names)]

	# Dont add 'gbif_' before gbif_lon or gbif_lat
	names(gbif_ctry)[-c(1, 2)] <- paste0('gbif_', names(gbif_ctry)[-c(1, 2)])

	#head(gbif_ctry)

	return(gbif_ctry)
}
