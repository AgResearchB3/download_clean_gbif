fRgbifGetPp <- function(a_sp_df) {

	library(rgbif)
	# see https://ropensci.org/tutorials/rgbif_tutorial/

	gs <- a_sp_df$canonicalName
	g_s <- sub(' ', '_', gs)
	pp_fn <- paste0('Gbif_', g_s, '.RData')
	pp_path_and_fn <- paste(gbif_dat_dir, pp_fn, sep = '/')

	if (file.exists(pp_path_and_fn)) {
			message("\n'", paste0(pp_fn, "' was already on disc - didn't try GBIF"))
		} else {
			message(paste0("\nNo file '", pp_fn, "' on disc, trying GBIF"))
			pp <- occ_search(taxonKey = a_sp_df$key, return = 'data', hasCoordinate = TRUE, limit = 200000)
	}

	# If pp_fn not on disc, or is NULL, or is empty dataframe then give error message
	if (!(file.exists(pp_path_and_fn)) && (is.null(pp) | is.character(pp) | (is.data.frame(pp) && nrow(pp) == 0))) { 
		message(paste("Failed to obtain presence points for", gs, "from GBIF"))
		rm(pp)
	} 

	## If pp exists then save as RData file
	if (exists('pp') & !file.exists(pp_path_and_fn)) {
		save(pp, file = pp_path_and_fn) # save new GBIF data
		message(paste(nrow(pp), "presence points for", gs, "saved to", pp_fn))
	}
	
	# progress bar- https://github.com/tidyverse/purrr/issues/149
  pb$tick()$print()

}
