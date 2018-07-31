f_03B_SelectGbifColsWithCtryDat <- function(gb_raw_dat) {

#---------------------------------------------------------
# Identify the columns that contains lon & lat
#---------------------------------------------------------
	# Longitude
	lon_col <- grep('lon', names(gb_raw_dat), ignore.case = TRUE)
	if (length(lon_col) > 1) message('Warning: >1 variable chosen for longitude')
	# Latitude
	lat_col <- grep('lat', names(gb_raw_dat), ignore.case = TRUE)
	nom_col <- grep('nomenclatural', names(gb_raw_dat), ignore.case = TRUE)
	lat_col <- lat_col[!lat_col %in% nom_col]
	if (length(lat_col) > 1) message('Warning: >1 variable chosen for latitude')

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

	gbif_ctry <- gbif[ , c(lon_col, lat_col, gbif_ctry_col)]

	names(gbif_ctry) <- c(paste0('gbif_', names(gbif_ctry)))

	#head(gbif_ctry)

	return(gbif_ctry)
}