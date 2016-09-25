### This file contains some utility functions for enabling us to specify graphic
### elements like color schemes, themes, etc. in one place.


#' Returns a default there for making plots.
#' @export
getPBTheme <- function() {
  return(ggplot2::theme_bw(base_size = 14))
}


defaultPalette = "Set1"
defaultLargePaletteGetter = colorRampPalette(RColorBrewer::brewer.pal(9, "Set1"))

#' Get the default color scheme, adding more colors if they are available.
#' @export
getPBColorScale <- function(numLevels = 9) {
  if (numLevels <= 9) {
    return(ggplot2::scale_colour_brewer(palette = defaultPalette))
  } else {
    return(ggplot2::scale_color_manual(values = defaultLargePaletteGetter(numLevels)))
  }
}


#' Get the default color scheme for fills, adding more colors if the current
#' palette is maxed out
#' @export
getPBFillScale <- function(numLevels = 9) {
  if (numLevels <= 9) {
    return(ggplot2::scale_fill_brewer(palette = "Set1"))
  } else {
    return(ggplot2::scale_fill_manual(values = defaultLargePaletteGetter(numLevels)))
  }
}
