# A 'Sandbox' script to batch download select SeaTac Airport files

library(purrr)
library(here)
source(here("download", "download_files.R")) # source download_files.R located on your local machine


# SeaTac Airport ----------------------------------------------------------


download.seatac.months.in.cy <- partial(download.seatac, year = "2020") # downloads PCO (traf-ops-MMYYYY) file
months <- sprintf("%02.0f", 1:6) # second argument represents the months. Edit for the months of interest

walk(months, download.seatac.months.in.cy)
