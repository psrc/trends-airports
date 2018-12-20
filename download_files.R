library(data.table)
library(openxlsx)
library(tidyverse)


# functions ---------------------------------------------------------------


# airports across US (annual)
# pass 4 digit year string; it will download and standardize filename for enplanements & cargo
download.faa <- function(year) { 
  yearabr <- substr(year, 3, 4)

  settings <- list(dir = "C:/Users/CLam/Desktop/trends-airports/Data",
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


# download ----------------------------------------------------------------


download.faa("2017") # downloads both enplanements and cargo


