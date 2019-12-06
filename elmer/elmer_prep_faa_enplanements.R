library(data.table)
library(openxlsx)

year <- 2018

source(file.path("..", "Desktop", "trends-airports", "elmer","elmer_prep_faa_functions.R"))

dt <- read.faa(year, "enplanements")

dt.clean <- clean.faa.enplanements(year, dt)

