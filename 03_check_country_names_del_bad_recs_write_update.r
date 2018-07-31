# 18-May-2018, updated 23_May-2018: Any NZ records are retained in this script. They are excluded in '07_get_nz_projections.r'

rm(list = ls())

library(plyr)
library(dplyr)
library(maptools) # loads sp too; for CRS, readShapePoly

#--------------------------------------------
# Constants
#--------------------------------------------
max_m_to_border <- 1500

base_dir <- '../DNZ/B_InsectNzProjections'

func_dir <- '../../R_functions'

gis_dir <- '../r_gis'

crs_geo <- CRS('+proj=longlat +ellps=WGS84 +datum=WGS84')  # geographical, datum WGS84

gbif_read_dir <-  paste(base_dir, 'gbif_records_cleaned', sep = '/')

gbif_write_dir <- paste(base_dir, 'gbif_recs_clean_cntrys_checked', sep = '/')

if (!dir.exists(gbif_write_dir)) dir.create(gbif_write_dir)

sf_read_dir <- '../sfs/general/rdata' 

sf_read_fn <- 'world_countries_wgs84.RData' # wld

#--------------------------------------------
# Functions
#--------------------------------------------

source(paste(func_dir, 'fDeleteAllEmptyColumnsInDf.r', sep = '/'))
source(paste(func_dir, 'fPlotBaseMapOfPts.r', sep = '/'))

source('f_03A_JoinGbifPpsToWldSfCtryData.r')
source('f_03B_SelectGbifColsWithCtryDat.r')
source('f_03C_IdRecsWithCtryDatThatDifferBetweenGbifAndWldSf.r')
source('f_03D_fAcceptSomeCountryDiscrepanciesBetweenShapeAndGbif.r')
source('f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder.r')

#---------------------------------------------------------
# Read world SF & get vector of GBIF files to process.
#---------------------------------------------------------

# Read world countries RData SF
load(paste(sf_read_dir, sf_read_fn, sep = '/')) 

pp_to_process <- dir(gbif_read_dir, pattern = ".RData") 

n_pp_files <- length(pp_to_process); n_pp_files

#---------------------------------------------------------
# Start file-by-file processing
#---------------------------------------------------------
#i<-3
for (i in 1: n_pp_files) {

	keep_me <- ls()[grep('f_03*', ls())]
	keep_me <- c(keep_me, 'max_m_to_border', 'can', 'crs_geo', 'fDeleteAllEmptyColumnsInDf', 'fPlotBaseMapOfPts', 'func_dir', 'gbif_read_dir', 'gbif_write_dir', 'i', 'n_pp_files', 'pp_to_process', 'wld')
	rm(list = ls()[!ls() %in% keep_me])

	#---------------------------------------------------------
	# Read one GBIF file & rename it
	#---------------------------------------------------------
	one_sp_pp <- paste0(gbif_read_dir, "/", pp_to_process[i])

	load(one_sp_pp)

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
		gbif <- gbif[-as.integer(gb_to_chk$chk), ]
    nrow(gbif)

	} # end if 

	#---------------------------------------------------------
	# Write cleaned records to RData
	#---------------------------------------------------------
	save(gbif, file = paste0(gbif_write_dir, '/', pp_to_process[i]))

	message(paste0(i, ' of ', n_pp_files, ': ', paste(gbif_write_dir, pp_to_process[i], sep = '/')))

	flush.console()

} # end for loop

dir(gbif_write_dir, pattern = '.RData')
