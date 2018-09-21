#---------------------------------------------------------
# Craig Phillips, 8-Apr-2016, updates 1-Dec-2016, Mar-2018, May-2018, Sep-2018
# Reads list of hazard species
# Tidys list & saves to CSV for use later
# Requests/saves species occurrence records from GBIF
#---------------------------------------------------------

library(plyr)
library(dplyr)
library(rgbif)
library(purrr)
# Purrr- See https://jennybc.github.io/purrr-tutorial/bk01_base-functions.html

rm(list = ls())

getwd()

#---------------------------------------------------------
# Constants
#---------------------------------------------------------
func_dir <- '../../R_functions'
base_dir <- '../pinus_radiata'

dir(base_dir, pattern = '.csv')

haz_fn <- 'overseas_radiata_pest_list_names.csv'

gbif_dat_dir <- paste(base_dir, 'gbif', sep = '/')
if (!dir.exists(gbif_dat_dir)) dir.create(gbif_dat_dir)

csv_out_dir <- paste(base_dir, 'csv_out_files', sep = '/') # for tidied spp list
if (!dir.exists(csv_out_dir)) dir.create(csv_out_dir)

rdata_out_dir <- paste(base_dir, 'rdata_out_files', sep = '/') # save for keys for P. radiata
if (!dir.exists(rdata_out_dir)) dir.create(rdata_out_dir)

csv_out_fn <- '01_out_haz_tidy.csv'

no_id <- c('spp.', 'spp', 'sp.', 'sp', '*', 'species', 'unknown', 'larvae', 'spp. larvae', '')

#---------------------------------------------------------
# Functions
#---------------------------------------------------------
source('fOnlyProcessFilesOnce.r')
source('fRgbifGetPp.r')

#dir(func_dir)
source(paste(func_dir, 'fGetIndicesOfCharInString.r', sep = '/'))

#---------------------------------------------------------
# Read names of hazard species to look for on GBIF. Omit incomplete names, tidy typos etc
#---------------------------------------------------------
haz_df <- read.csv(paste(base_dir, haz_fn, sep = '/'), as.is = TRUE)

#glimpse(haz_df)

# Querying GBIF about whether it has records for each species (see below) can reveal species with none. These names may have typos, & manually searching for each of the possibly incorrect names in GBIF can sometimes reveal the probably correct ones. (I guess manual search must use fuzzy matching.) Examples of typos from the chicory hazard list were the species names 'sonchii' rather than 'sonchi', 'nubialis' rather than 'nubilalis', & 'rugosa' rather than 'rugulosa'.

#---------------------------------------------------------
# Clean up the hazard list
# Pinus radiata 
#---------------------------------------------------------

names(haz_df) <- map_chr(names(haz_df), function(x) tolower(x))
names(haz_df) <- c('order_family', 'current_name', 'insect_name_as_published', 'synonyms', 'comments')

haz_df$space <- unlist(regexpr(' ', haz_df$insect_name_as_published))
haz_df$haz_gen <- substr(haz_df$insect_name_as_published, 1, haz_df$space)
haz_df$haz_gen <- trimws(haz_df$haz_gen)

haz_df$haz_sp <- substr(haz_df$insect_name_as_published, haz_df$space + 1, nchar(haz_df$insect_name_as_published))
haz_df$space <- unlist(regexpr(' ', haz_df$haz_sp))
haz_df$haz_sp <- substr(haz_df$haz_sp, 1, haz_df$space)
haz_df$haz_sp <- trimws(haz_df$haz_sp)

haz_df %>%
	filter(!haz_gen %in% no_id & !haz_sp %in% no_id) %>%
	mutate(gen_sp  = paste(haz_gen, haz_sp)) %>%
	dplyr::select(gen_sp, haz_gen, haz_sp) %>%
	distinct(gen_sp, .keep_all = TRUE) %>%
	arrange(gen_sp) -> spp_df

#---------------------------------------------------------
# Save tidied hazard list
#---------------------------------------------------------
write.csv(spp_df, file = paste(base_dir, csv_out_fn, sep = '/'), row.names = FALSE)

#---------------------------------------------------------
# Don't request GBIF data that is already on file
#---------------------------------------------------------
files_to_get <- paste0('Gbif_', spp_df$gen_sp, '.RData')
files_to_get <- sub(' ', '_', files_to_get)
already_done <- dir(gbif_dat_dir, pattern = '.RData')
if (length(already_done) > 0) files_to_get <- files_to_get[-which(files_to_get %in% already_done)]
gen_sp_to_get <- sub('Gbif_', '', files_to_get)
gen_sp_to_get <- sub('.RData', '', gen_sp_to_get)
gen_sp_to_get <- sub('_', ' ', gen_sp_to_get)

spp_df <- filter(spp_df, gen_sp %in% gen_sp_to_get)

#---------------------------------------------------------
# Use rgbif to check which species have records at GBIF & get GBIF's keys for each species.
#---------------------------------------------------------
fGetSppKeysFromGbif <- function(x) name_suggest(q = x, rank =  'species', fields = c('key', 'canonicalName'))

keys <- map(spp_df$gen_sp, fGetSppKeysFromGbif)
names(keys) <- spp_df$gen_sp
no_recs <- names(keys[map(keys, length) == 0])

message('There are no GBIF records of:'); no_recs
# chicory: "Microtus arvensis"  "Neotrama pamirica"  "Uroleucon chicorii"
# Pinus radiata:  86 species

keys2 <- keys[!names(keys) %in% no_recs]
nrow(spp_df) - length(keys2) == length(no_recs) # hopefully TRUE
save(keys2, file = paste(rdata_out_dir, '01_out_keys2.RData', sep = '/'))

# P. radiata: Some tibbles have >1 rows, which currently destroys function fRgbifGetPp
# Omit them here, while developing fix
keys3 <- discard(keys2, function(x) nrow(x) > 1)

#---------------------------------------------------------
# Get lon/lat records from GBIF by species key 
# Progress bar- https://github.com/tidyverse/purrr/issues/149
#---------------------------------------------------------
if (length(keys3) > 0) { # 289 species
	pb <- progress_estimated(length(keys3)) # progress bar- pb is used by fRgbifGetPp
	walk(keys3, fRgbifGetPp)
} else {
	message('All available geo-referenced GBIF data are already on disc')
}


length(keys2)
key_chk <- keys2[1: 10[1, ]]