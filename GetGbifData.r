##----------------------------------------------------------
## Craig Phillips, AgResearch, July 2015
## Get GBIF presence points for a species, either from disc if already stored there, otherwise from GBIF
##----------------------------------------------------------

#setInternet2(TRUE)
library(dismo) # for function gbif

## Create standard file name for presence points & give message saying whether or not it's already on disc
myPps <- paste0(gbif_download_dir, "Gbif_", genus, "_", species, ".RData" )

if (file.exists(myPps)) {
    message("'", paste0(myPps, "' is already on disc. Won't try GBIF"))
	} else {
    message(paste0("No file '", myPps, "' on disc, trying GBIF"))
    pp <- tryCatch(gbif(genus, species, geo = TRUE, removeZeros = TRUE, end = max_gbif_records), error = function(e) {paste("Problem with GBIF")})
  }

## If MyPps not on disc, & (pp == "Problem with GBIF", or is NULL, or is an empty dataframe) then give error message

if (!(file.exists(myPps)) && (is.null(pp) | is.character(pp) | (is.data.frame(pp) && nrow(pp) == 0))) { 
  message(paste("Failed to obtain presence points for", genus, species, "from GBIF"))
  rm(pp)
} 

## If pp exists then save as RData file
if (exists('pp') & !file.exists(myPps)) {
  save(pp, file = myPps) # save new GBIF data
  message(paste(nrow(pp), "presence points for", genus, species, "saved to", gbif_result_dir))
}

message("Processed ", i, " species of ", nsp, "\n")


