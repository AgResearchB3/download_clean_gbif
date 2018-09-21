fOnlyProcessFilesOnce <- function(read_dir, write_dir) {

#read_dir <- gbif_read_dir
#write_dir <- gbif_write_dir

	files_to_process <- dir(read_dir, pattern = '.RData') 
	if (length(files_to_process) == 0) stop('Zero files in read directory')

	files_processed  <- dir(write_dir, pattern = '.RData') 

	if (length(files_to_process) > 0 & length(files_processed) > 0) {
		message(cat(length(files_processed), 
								'existing processed files will not be checked again:\n', 
								 files_to_process[which(files_to_process %in% files_processed)], 
								'\n'))
		files_to_process <- files_to_process[-which(files_to_process %in% files_processed)]
	}

	return(files_to_process)

}
