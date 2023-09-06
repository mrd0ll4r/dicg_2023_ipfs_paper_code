library(tikzDevice)
library(viridis)

options(tikzDefaultEngine = "pdftex")
options(tikzDocumentDeclaration = "\\documentclass[10pt]{article}")

scientific_10 <- function(x) {
  parse(text=gsub("e", " %*% 10^", gsub("\\+","",scales::scientific_format()(x))))
}
