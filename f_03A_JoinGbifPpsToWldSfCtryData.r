f_03A_JoinGbifPpsToWldSfCtryData <- function(gbif) {
#dim(gbif)

#---------------------------------------------------------
# Convert presence points from GBIF into spatial object
#---------------------------------------------------------
if ('gbif_lon' %in% names(gbif) & 'gbif_lat' %in% names(gbif)) {
			pts <- gbif[ , c('gbif_lon', 'gbif_lat')]
	} else if ('lon' %in% names(gbif) & 'lat' %in% names(gbif)) {
			pts <- gbif[ , c('lon', 'lat')]
	} else {
			stop('Cannot find column names for x and y coordinates')
}
	
pts <- SpatialPoints(pts, proj4string = crs_geo)
#str(pts)

#---------------------------------------------------------
# Plot all records
#---------------------------------------------------------
plot_recs <- FALSE

 if (plot_recs) {
	bb <- bbox(pts[pts])
	plot(wld, xlim = c(bb[1,]), ylim = c(bb[2, ]), col = 'grey80')
	points(pts, pch = 16, col = 'red', cex = 1)
}

#---------------------------------------------------------
# Join GBIF presence point locations with the world countries they occur in, as indicated by the world shapefile
#---------------------------------------------------------
#attributes(wld)$proj4string
#crs_geo
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


