# About
This repo contains scripts related to the annual FAA and SeaTac monthly passenger-cargo-operations summaries. A combination of scripts are available to do the following:

- export summaries to excel
- limited graphs/plots

The following former scripts have been moved to the Elmer repo:
- download file or download a batch of files
- perform ETL processes into Elmer

## Installation
It is recommended that you use the [latest version of R](https://cran.r-project.org/), and the [RStudio IDE, a.k.a. RStudio Desktop](https://rstudio.com/products/rstudio/download/)

In RStudio, install the following libraries
``install.packages(c("tidyverse", "data.table", "openxlsx", "DBI", "odbc", "here"), dependencies = TRUE)``

## To Start
In the RStudio IDE go to `File > Open Project` and select `trends-airports.Rproj` that is in the repo. By opening the project file, the working directory will automatically be set!

## Plot
- Files ending in `.Rmd`
- These files will read and compile a specific dataset for all available years  
  - `airports_faa.Rmd` reads from Elmer
  - `airports_seatac.Rmd` currently reads from the Y: drive. It will transition to read from Elmer soon.
- The option to export formatted data to excel lives in a code chunk. Subject to change. Stay tuned.
  - Edit the `outdir` setting

