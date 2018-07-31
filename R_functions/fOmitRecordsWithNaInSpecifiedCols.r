fOmitRecordsWithNaInSpecifiedCols <- function(data_frame, col_names) {
  df_without_na <- complete.cases(data_frame[, col_names])
  return(data_frame[df_without_na, ])
}
