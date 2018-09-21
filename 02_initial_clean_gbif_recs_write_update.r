#----------------------------------------------------------------
# CBP, April 2018. 
# Read GBIF data, omit incorrect/uncertain records, write cleaned data to new file in different directory
# Loads RData, checks if DF called 'pps'. If so, changes to 'pp', deletes 'pps' & save 'pp' back to original RData filename.
# Changes names of lon/lat variables to 'gbif_lon' & 'gbif_lat' 
# Omits:
# Records with high coordinate uncertainty
# Records with issues
# Records with bad basisofrecord
# Can screen concatenated locality 'cloc'
# Records without coordinates
# NA columns

#----------------------------------------------------------------
library(plyr)
library(dplyr)
library(purrr)

rm(list = ls())
getwd()

#--------------------------------------------
# Constants
#--------------------------------------------
# Coordinate uncertainty in m. Records with > values will be omitted.
coord_unc <- 10000

base_dir <- '../DNZ/B_InsectNzProjections'
#base_dir <- '../kiwifruit'
#base_dir <- '../nz_spread'
#base_dir <- '../DNZ/D_Insects_ChicoryLucerneMaize'
#base_dir <- '../pinus_radiata'

func_dir <- '../../R_functions'

#gbif_read_dir <- paste(base_dir, 'gbif_records', sep ='/')
gbif_read_dir <- paste(base_dir, 'gbif_records', sep ='/')

gbif_write_dir <- paste(base_dir, 'gbif_records_cleaned', sep ='/')
if (!dir.exists(gbif_write_dir)) dir.create(gbif_write_dir)

#--------------------------------------------
# Functions
#--------------------------------------------
dir(func_dir)

source(paste(func_dir, 'fDeleteAllEmptyColumnsInDf.r', sep = '/'))
source(paste(func_dir, 'fOmitRecordsWithNaInSpecifiedCols.r', sep = '/'))
source('fOnlyProcessFilesOnce.r')

source('f_02A_ScreenVarsForVals.r')
source('f_02B_get_index_of_lon_column.r')
source('f_02B_get_index_of_lat_column.r')
source('f_02_main_clean_pp.r') 

#--------------------------------------------
# Clean the presence points
#--------------------------------------------

pp_to_process <- fOnlyProcessFilesOnce(gbif_read_dir, gbif_write_dir) 

length(pp_to_process)

if (length(pp_to_process) > 0) {
	walk(pp_to_process, f_02_main_clean_pp)
} else {
	message('All available files have already been cleaned')
}

warnings()
gbif_write_dir
dir(gbif_write_dir, pattern = '.RData')
