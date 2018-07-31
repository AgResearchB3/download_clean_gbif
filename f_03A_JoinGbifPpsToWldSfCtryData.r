f_03A_JoinGbifPpsToWldSfCtryData <- function(gb_raw_dat) {

	#dim(gbif)

#---------------------------------------------------------
# Identify the columns that contains lon & lat
#---------------------------------------------------------
	# Longitude
	lon_col <- grep('lon', names(gbif), ignore.case = TRUE)
	if (length(lon_col) > 1) message('Warning: >1 variable chosen for longitude')
	# Latitude
	lat_col <- grep('lat', names(gbif), ignore.case = TRUE)
	nom_col <- grep('nomenclatural', names(gbif), ignore.case = TRUE)
	lat_col <- lat_col[!lat_col %in% nom_col]
	if (length(lat_col) > 1) message('Warning: >1 variable chosen for latitude')

	#names(gbif)[c(lon_col, lat_col)]

#---------------------------------------------------------
# Convert presence points from GBIF into spatial object
#---------------------------------------------------------
	pts <- gbif[ , c(lon_col, lat_col)]
	pts <- SpatialPoints(pts, proj4string = crs_geo)
	#str(pts)

#---------------------------------------------------------
# Plot all records
#---------------------------------------------------------
	#bb <- bbox(pts[pts])
	#plot(wld, xlim = c(bb[1,]), ylim = c(bb[2, ]), col = 'grey80')
	#points(pts, pch = 16, col = 'red', cex = 1)

#---------------------------------------------------------
# Join GBIF presence point locations with the world countries they occur in, as indicated by the world shapefile
#---------------------------------------------------------
	pts_ctry <- over(pts, wld)

#---------------------------------------------------------
# Identify which world shapefile data columns give country details for each presence point. The resulting vector of column indices, sf_ctry_col, is used to show just the data of interest.
#---------------------------------------------------------
	#names(wld@data)

	sf_ctry_col <-                grep('country', names(wld@data), ignore.case = TRUE)
	sf_ctry_col <- c(sf_ctry_col, grep('iso',     names(wld@data), ignore.case = TRUE))
	sf_ctry_col <- c(sf_ctry_col, grep('name',    names(wld@data), ignore.case = TRUE))

	not_col <- grep('was_iso', names(wld@data), ignore.case = TRUE)

	sf_ctry_col <- sf_ctry_col[!sf_ctry_col %in% not_col]

	#names(wld@data)[sf_ctry_col]

	pts_ctry <- pts_ctry[, sf_ctry_col]

#---------------------------------------------------------

	return(pts_ctry)

}


