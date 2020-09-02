# About
This repo contains scripts related to the annual FAA and SeaTac monthly passenger-cargo-operations summaries. A combination of scripts are available to do the following:

- export summaries to excel
- limited graphs/plots

Do not use files in the `download` or `elmer` subdirectories. The scripts pertaining to the following have been or are in the process of moving to the Elmer repo:  

- download file or download a batch of files  
- perform ETL processes into Elmer

## Installation
It is recommended that you use the [latest version of R](https://cran.r-project.org/), and the [RStudio IDE, a.k.a. RStudio Desktop](https://rstudio.com/products/rstudio/download/)

In RStudio, install the following libraries
``install.packages(c("tidyverse", "data.table", "openxlsx", "DBI", "odbc", "here"), dependencies = TRUE)``

## To Start
In the RStudio IDE go to `File > Open Project` and select `trends-airports.Rproj` that is in the repo. By opening the project file, the working directory will automatically be set!

## Seatac Airport (Passenger-Cargo-Operations)
- Scripts can be found in the `summaries` subdirectory
  - `airports_seatac_export.R` reads from Elmer and exports formatted data to an excel workbook
  - `airports_seatac_plots.Rmd` is an RNotebook and provides high level graphs

## FAA
- Files pertaining to FAA data are usable. Code files and organization may change in the near future.
- These files will read and compile a specific dataset for all available years  
  - `airports_faa.Rmd` reads from Elmer



