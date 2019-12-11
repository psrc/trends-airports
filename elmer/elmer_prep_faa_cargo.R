# This script will read the latest year's cargo (as landed weight in lbs) data directly from the faa website,
# munge, and write into Elmer's staging area. Use the .ipynb to update dims and facts in Elmer.

library(data.table)
library(openxlsx)
library(odbc)
library(DBI)

year <- 2014
stgname <- "faa_cargo"

source(file.path("..", "Desktop", "trends-airports", "elmer","elmer_prep_faa_functions.R"))

dt <- read.faa(year, "cargo")

dt.clean <- clean.faa.cargo(year, dt)

elmer_connection <- db.connect("Elmer")

# DBI::dbGetQuery(elmer_connection, "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA")

dbWriteTable(elmer_connection, Id(schema = "stg", table = stgname), as.data.frame(dt.clean), overwrite = TRUE)

dbDisconnect(elmer_connection)
