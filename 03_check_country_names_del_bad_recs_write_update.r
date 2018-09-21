# 18-May-2018, updated 23_May-2018: Any NZ records are retained in this script. They are excluded in '07_get_nz_projections.r'

rm(list = ls())

library(plyr)
library(dplyr)
library(maptools) # loads sp too; for CRS, readShapePoly
library(purrr)

#--------------------------------------------
# Constants
#--------------------------------------------
max_m_to_border <- 1500

base_dir <- '../DNZ/B_InsectNzProjections'
#base_dir <- '../nz_spread'
#base_dir <- '../DNZ/D_Insects_ChicoryLucerneMaize'
#base_dir <- '../pinus_radiata'

func_dir <- '../../R_functions'
gis_dir <- '../r_gis'

#crs_geo <- CRS('+proj=longlat +ellps=WGS84 +datum=WGS84') # WGS84
crs_geo <- CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0')

#gbif_read_dir <-  paste(base_dir, 'gbif_clean', sep = '/')
gbif_read_dir <-  paste(base_dir, 'gbif_records_cleaned', sep = '/')

#gbif_write_dir <- paste(base_dir, 'gbif_clean_ctry_ok', sep = '/')
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
source('fOnlyProcessFilesOnce.r')
source('f_03_main_clean_pp.r')

#---------------------------------------------------------
# Read world SF & get vector of GBIF files to process.
#---------------------------------------------------------
load(paste(sf_read_dir, sf_read_fn, sep = '/')) # world countries RData SF

pp_to_process <- fOnlyProcessFilesOnce(gbif_read_dir, gbif_write_dir) 
# P. radiata - look out for Gbif_Thaumetopoea_pityocampa.RData - it has 82985 records
# pp_to_process <- pp_to_process[!pp_to_process == 'Gbif_Thaumetopoea_pityocampa.RData']

#---------------------------------------------------------
# Process each file
# Check if f_03_main_clean_pp saves files with 0 records
#---------------------------------------------------------
if (length(pp_to_process) > 0) {
	walk(pp_to_process, f_03_main_clean_pp)
} else {
	message('All available files have already been cleaned')
}

dir(gbif_write_dir, pattern = '.RData')

