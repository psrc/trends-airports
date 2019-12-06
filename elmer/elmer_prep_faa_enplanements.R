# This script will read the latest year's enplanements (passenger boardings) data directly from the faa website
# munge and write into the staging area of Elmer. Use the .ipynb to update dims and facts in Elmer.

library(data.table)
library(openxlsx)
library(odbc)
library(DBI)

year <- 2018
stgname <- "faa_enplanements"

source(file.path("..", "Desktop", "trends-airports", "elmer","elmer_prep_faa_functions.R"))

dt <- read.faa(year, "enplanements")

dt.clean <- clean.faa.enplanements(year, dt)

elmer_connection <- db.connect("Elmer")

# DBI::dbGetQuery(elmer_connection, "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA")

dbWriteTable(elmer_connection, Id(schema = "stg", table = stgname), as.data.frame(dt.clean), overwrite = TRUE)

dbDisconnect(elmer_connection)

