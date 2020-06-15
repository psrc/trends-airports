# This script preps Seatac Airport PCO data not in Elmer to Elmer
library(data.table)
library(tidyverse)

# see download_files.R and or download_files_batch.R to download necessary files

# ensure dir contains only the files/data to be appended to Elmer 
dir <- "C:/Users/clam/Desktop/trends-airports/Data"

compile.seatac.pco <- function() {
  # This function merely compiles all files in dir to one flat file, three columns: type, value, date

  efiles <- list.files(dir, pattern = "traf-ops-\\d{6}", full.names = T)
  dts <- NULL
  for (efile in efiles) {
    fname <- basename(efile)
    month.num <- str_extract(fname, "\\d{2}")
    year <- str_extract(fname, "\\d{4}(?=\\.x)")
    dt <- readxl::read_excel(efile, skip =3)
    setDT(dt)
    cols <- c("...1", colnames(dt)[str_which(colnames(dt), paste0("^", month.name[as.numeric(month.num)],".*", year))])
    t <- dt[!is.na(get(eval(cols[2]))), ..cols][, `:=` (date = lubridate::ymd(paste(year, month.num, 1)))]
    setnames(t, cols, c("type", "value"))
    t[, type := str_to_lower(type)]
    ifelse(is.null(dts), dts <- t, dts <- rbindlist(list(dts, t), use.names = T))
  }
  return(dts)
}

wrangle.seatac.pco <- function(dt) {
  # This function takes a compiled data.table and wrangles. Will add 3 additional cols for type grouping
  
  cols.remove <- na.omit(unique(str_extract(dt[, type], ".*total.*")))
  ops.cat <- c("air carrier", "air taxi", "general aviation", "military")
  dt.sub <- dt[!(type %in% cols.remove), ]
  dt.sub[, type_group_1 := str_trim(str_extract(dt.sub[, type], ".*(?=-)"))]
  dt.sub[, type_group_2 := str_trim(str_replace(dt.sub[, type_group_1], "^domestic|international", ""))]
  dt.sub[, type_group_3 := switch(type_group_2, 
                                  "passengers" = "passengers", 
                                  "air mail" = "cargo", 
                                  "air freight" = "cargo"), by = 'type_group_2']
  new.cols <- paste0("type_group_", 1:2)
  dt.sub[type %in% ops.cat, (new.cols) := type
         ][type %in% ops.cat, type_group_3 := "operations"]
  setcolorder(dt.sub, c("date", "value","type", paste0("type_group_", 1:3)))
  
  return(dt.sub)
}


# Run ---------------------------------------------------------------------


df <- compile.seatac.pco()
dt <- wrangle.seatac.pco(df)


# QC ----------------------------------------------------------------------

group.cols <- paste0("type_group_", 1:3)

for (group.col in group.cols) {
  if (group.col == "type_group_1") {
    # group 1, dom + intl pass, dom + intl freight
    print(dt[str_detect(get(eval(group.col)), ".*passengers$")|str_detect(get(eval(group.col)), ".*freight$"), 
             .(estimate = sum(value)), by = .(month(get("date")), year(get("date")), group = get(eval(group.col)))]
          )
  } else if (group.col == "type_group_2") {
    # group 2, mail, freight
    print(dt[str_detect(get(eval(group.col)), ".*mail$")|str_detect(get(eval(group.col)), ".*freight$"), 
             .(estimate = sum(value)), by = .(month(get("date")), year(get("date")), group = get(eval(group.col)))]
    )
  } else {
    # group 3, grand total
    print(dt[, .(estimate = sum(value)), by = .(month(get("date")), year(get("date")), group = get(eval(group.col)))])
  }
}  
  


# Export to Elmer ---------------------------------------------------------


