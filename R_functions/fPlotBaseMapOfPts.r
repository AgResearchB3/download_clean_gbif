fPlotBaseMapOfPts <- function(longitude, latitude, plot_title, all_world = FALSE) {

  library(maptools) # for simple world map
  data(wrld_simpl) # get world map
  
  if (all_world == FALSE) {

    plot(wrld_simpl, xlim = c(min(longitude), max(longitude)), ylim = c(min(latitude), max(latitude)), axes = TRUE, col = 'light yellow', main = plot_title)

  } else {

  plot(wrld_simpl, axes = TRUE, col = 'light yellow', main = plot_title)
  }
  
  points(longitude, latitude, col = 'red', cex = 1, pch = 15, xlab = "",ylab = "")

}

