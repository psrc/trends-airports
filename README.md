# About
This repo contains scripts related to the annual FAA and SeaTac monthly passenger-cargo-operations summaries. A combination of scripts are available to do the following:

- download file or download a batch of files
- perform ETL processes into Elmer
- export summaries to excel
- limited graphs/plots

## Installation
It is recommended that you use the [latest version of R](https://cran.r-project.org/), 

In RStudio, install the following libraries
``install.packages(c("tidyverse", "data.table", "openxlsx", "DBI", "odbc", "here"), dependencies = TRUE)``

## Download Files
- `download/download_files.R` and/or `download/download_files_batch`  
- Edit the `data.dir` setting in `download/download_files.R` to the location where data should be stored.
- The default setting `data.dir <- here("Data")` assumes a `Data` subdirectory from the project root.

## Plot
- Files ending in `.Rmd`
- These files will read and compile a specific dataset for all available years
- The option to export formatted data to excel lives in a code chunk. Subject to change. Stay tuned.
  - Edit the `outdir` setting

