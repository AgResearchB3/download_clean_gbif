
## Craig Phillips, AgResearch, 4 July 2017
## Mariona Roige, AgResearch, 25/05/2018

rm(list = ls())
library(plyr)
library(dplyr)
library(maptools) # loads sp too; for CRS, readShapePoly

#--------------------------------------------
# Directories
#--------------------------------------------

my_wd <- 'C:/00_2018/03_CABIvsGBIF/PestProfiles' 
setwd(my_wd);

func_dir <- './R_functions'
if (!dir.exists(func_dir)) dir.create(func_dir)
gbif_download_dir <- './SpeciesSource/GbifData/'	
if (!dir.exists(gbif_download_dir)) dir.create(gbif_download_dir)	
gbif_read_dir <- gbif_download_dir
gbif_write_dir <- './SpeciesSource/Gbif_records_cleaned'
if (!dir.exists(gbif_write_dir)) dir.create(gbif_write_dir)
gbif_read_cleaned_dir <- gbif_write_dir
gbif_write_country_cleaned_dir <- './SpeciesSource/Gbif_recs_clean_cntrys_checked'
if (!dir.exists(gbif_write_country_cleaned_dir)) dir.create(gbif_write_ctry_cleaned_dir)

#--------------------------------------------
# Constants
#--------------------------------------------

coord_unc <- 1000000 # 1000 km. Coordinate uncertainty in m. Records with > values will be omitted.
max_gbif_records <- 5000 # most spp have < 2000, but a few have 10s of 1000s
max_m_to_border <- 10000 # distance in meters.  

#--------------------------------------------
# Functions
#--------------------------------------------

source(paste(func_dir, 'f_02A_ScreenVarsForVals.r', sep = '/'))
source(paste(func_dir, 'f_03A_JoinGbifPpsToWldSfCtryData.r', sep = '/'))
source(paste(func_dir, 'f_03B_SelectGbifColsWithCtryDat.r', sep = '/'))
source(paste(func_dir, 'f_03C_IdRecsWithCtryDatThatDifferBetweenGbifAndWldSf.r', sep = '/'))
source(paste(func_dir, 'f_03D_fAcceptSomeCountryDiscrepanciesBetweenShapeAndGbif.r', sep = '/'))
source(paste(func_dir, 'f_03E_GetDistBetweenSuspectPpAndGbifCountryBorder.r', sep = '/'))
source(paste(func_dir, 'fPlotBaseMapOfPts.r', sep = '/'))
source(paste(func_dir, 'fDeleteAllEmptyColumnsInDf.r', sep = '/'))
source(paste(func_dir, 'fOmitRecordsWithNaInSpecifiedCols.r', sep = '/'))














