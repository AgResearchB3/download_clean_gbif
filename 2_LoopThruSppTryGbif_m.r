## Craig Phillips, AgResearch, 4 July 2017
## Mariona Roige, AgResearch, 25/05/2018

source('1_SetConstants.r') # modified by Mariona 25/05/18
dir('SpeciesSource', pattern = '.csv')

## Read species list from CSV file
spp <- read.csv('SpeciesSource/specieslist.csv', as.is = TRUE) 
							
glimpse(spp)

nrow(spp) # 1079
spp <- filter(spp, !sp %in% '')
nrow(spp) # 10

spp$new_gensp <- paste(spp$gen, spp$sp) 

spp <- unique(spp$new_gensp)
nsp <- length(spp); nsp # Mariona : 1063 sp now 

for (i in 1: nsp) { 
  genus_species <- spp[i] # eg, "Acacia catechu"
  genus <- strsplit(genus_species, " ")[[1]][1]
  species <- strsplit(genus_species, " ")[[1]][2]
  source("GetGbifData.r") # only tries GBIF if data not on disc, produces presence points 'pp'
}

length(dir(gbif_download_dir)) #


 