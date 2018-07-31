f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder <- function(chk_recs) {

# Craig Phillips, 23-May-2018 
# When mapped to a world shapefile, a GBIF coordinate may occur in a country other than the one named in its GBIF country field. This function gets the distance (meters) between the coordinate & the border of its GBIF country. (Coordinates that are close to the border might be deemed acceptable.) 
# Coordinates for each GBIF country processed separately, using by()
# For each GBIF country, world SF is clipped to that country
# Distance between coordinates and the GBIF country measured using geosphere::dist2Line
# Results (list of DFs) compiled into one DF using for each country and returned as DF, using data.table::rbindlist
# Updated 13-Jun_2018 to catch error that occurs if a GBIF ISO code is absent from the shapefile ISO codes.
#---------------------------------------------------------

library(geosphere)

chk_recs <- gb_to_chk

#---------------------------------------------------------
# Identify the columns that contain lon & lat
#---------------------------------------------------------
# Longitude
lon_col <- grep('lon', names(chk_recs), ignore.case = TRUE)
if (length(lon_col) > 1) stop('Error: >1 variable chosen for longitude')

# Latitude
lat_col <- grep('lat', names(chk_recs), ignore.case = TRUE)
lat_col <- chk_recs[,lat_col, drop = FALSE]   # Important the drop = FALSE cos otherwise no lat_col is selected when there's only one column that contains the string 'lat' .
lat_col_good <- Filter(is.numeric, lat_col)
lat_col <- which(names(chk_recs) == names(lat_col_good))
#nom_col <- grep('nomenclatural', names(chk_recs), ignore.case = TRUE) ## Ok, this is a check that Craig put here so that avoids finding the 'lat' strings in the column named 'nomenclatural'
#lat_col <- lat_col[!lat_col %in% nom_col]							   ## I can probably skip this if I do the Filter by is.numeric.
 
if (length(lat_col) > 1) stop('Error: >1 variable chosen for latitude')

#---------------------------------------------------------
# Some GBIF files have countrycode, some ISO2, some both. Need 1 to use in by() clause, so copy 1 or other to temporary var called 'chk_recs$gbif_iso_tmp'
#---------------------------------------------------------
chk_recs$gbif_iso_tmp <- NA

if (any(grep('gbif_countrycode', names(chk_recs)))) {
	chk_recs$gbif_iso_tmp <- chk_recs$gbif_countrycode
} else if (any(grep('gbif_ISO2', names(chk_recs)))) {
	chk_recs$gbif_iso_tmp <- chk_recs$gbif_ISO2
} else stop('Error in f_03E... : No GBIF ISO code in chk_recs')

#---------------------------------------------------------
# Check if all GBIF ISO codes occur in the shapefile. Exclude any that don't from the records that will have distances calculated, & instead assign them a distance ('meters') = NA.
#---------------------------------------------------------
if (!all(unique(chk_recs$gbif_iso_tmp) %in% unique(wld$ISO2))) {
	chk_recs_no_wld_iso <- filter(chk_recs, !gbif_iso_tmp %in% unique(wld$ISO2)) 
	chk_recs_no_wld_iso$meters <- NA
	chk_recs <- filter(chk_recs, gbif_iso_tmp %in% unique(wld$ISO2))
}

#---------------------------------------------------------
# Function to pass to subsequent by() clause
#---------------------------------------------------------

recs <- chk_recs

calc_m_to_country_border <- function(recs) {

	pts <- recs[ , c(lon_col, lat_col), drop = FALSE]
		pts2 <- recs[ , c(lon_col, lat_col), drop = FALSE]	# get coordinates
	pts <- SpatialPoints(pts, proj4string = crs_geo) # convert to spatial objects
	gb_iso <- unique(recs$gbif_iso_tmp) # get country code

	if (gb_iso != '' & !is.na(gb_iso)) { # if country code exists
		wld_clip <- wld[wld$ISO2 %in% gb_iso, ] # clip SF to GBIF country code
		dist_mat <- as.data.frame(geosphere::dist2Line(p = pts, line = wld_clip)) # get distances
		recs <- cbind(recs, meters = round(dist_mat[, 1], 0)) # bind with recs
	} else recs$meters <- NA # if no country code then no distance

	return(recs)

} # end of function 'calc_m_to_country_border'

#---------------------------------------------------------
# Calculate distances with records grouped by country code
#---------------------------------------------------------


distances <- by(chk_recs, chk_recs$gbif_iso_tmp, calc_m_to_country_border)

#---------------------------------------------------------
# Convert list of DFs to DF
#---------------------------------------------------------
dist_df <- as.data.frame(data.table::rbindlist(distances))

#---------------------------------------------------------
# Add any records for which no distances could be calculated (meters = NA) to the results
#---------------------------------------------------------
if (exists('chk_recs_no_wld_iso')) dist_df <- rbind(dist_df, chk_recs_no_wld_iso)

dist_df$gbif_iso_tmp <- NULL # delete temporary var

return(dist_df)

} # end of function 'f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder'
