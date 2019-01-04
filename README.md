## Installation
It is recommended that you use the [latest version of R](https://cran.r-project.org/), 

In RStudio, install the following libraries or update the package, data.table, to at least version 1.11
``install.packages(c("tidyverse", "data.table", "openxlsx"), dependencies = TRUE)``

## download_files.R
- This file will be a collection of functions to download specific datasets. 
- Edit the `dir` setting on line 14 (subject to change) to the location where data is stored. 

## .Rmd
- This file will read and compile a specific dataset for all available years with the option to export formatted data to excel.
- Edit the `dir` setting on line 11 (subject to change) to the location where data is stored.
