#  This script contains functions to download FAA data and SeaTac Airport's PCO data

library(data.table)
library(openxlsx)
library(tidyverse)

# data.dir <- "C:/Users/CLam/Desktop/trends-airports/Data"
data.dir <- "Y:/Perf Trends/Active_Trends/SeaTac_Airport/Data"

# functions ---------------------------------------------------------------


# airports across US (annual)
# pass 4 digit year string; it will download and standardize filename for enplanements & cargo
download.faa <- function(year) { 
  yearabr <- substr(year, 3, 4)

  settings <- list(dir = data.dir,
                   file.name.enp = paste0("cy", yearabr, "-commercial-service-enplanements.xlsx"),
                   file.name.cargo = paste0("cy", yearabr, "-cargo-airports.xlsx"),
                   url ="https://www.faa.gov/airports/planning_capacity/passenger_allcargo_stats/passenger/media/"
                   )
 
  local.file.enp <- paste0("cy", yearabr, "-commercial-service-enplanements.xlsx")
  local.file.cargo <- paste0("cy", yearabr, "-cargo-airports.xlsx")
  
  name.list <- list(enpmts = c(settings$file.name.enp, local.file.enp), 
                    cargo = c(settings$file.name.cargo, local.file.cargo))
  for (i in 1:length(name.list)) {
    url.file <- paste0(settings$url, name.list[[i]][1])
    download.file(url.file, file.path(settings$dir, name.list[[i]][2]), mode="wb")
  }
 cat("\nSuccessfully downloaded enplanements and cargo data\n")
}

# SeaTac airport (monthly)
# pass 2 digit month string and 4 digit year string; it will download and standardize filename for PCO files
download.seatac <- function(month, year) {
  tryCatch(
    {settings <- list(dir = data.dir,
                      file.name = paste0("traf-ops-", month, year, ".xls"),
                      url ="https://www.portseattle.org/pos/StatisticalReports/Public/"
    )
    
    local.file <- settings$file.name
    url.file <- paste0(settings$url, settings$file.name)
    download.file(url.file, file.path(settings$dir, local.file), mode="wb")
    },
    error=function(cond) {
      message("File does not exist")
    }
  )
 
}

# download examples-----------------------------------------------------------


# download.faa("2017") # downloads both enplanements and cargo
# download.seatac("11", "2018") # downloads PCO (traf-ops-MMYYYY) file

