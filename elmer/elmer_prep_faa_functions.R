read.faa <- function(year, datatype = c("enplanements", "cargo")) {
  # This function is intended for appending new data to what exists in Elmer
  # it will read into cache directly without downloading
  # will remove subtotals that exist in spreadsheet
  
  faa.url.root <- "https://www.faa.gov/airports/planning_capacity/passenger_allcargo_stats/passenger/media/"
  yearabr <- substr(year, 3, 4)
  ifelse(datatype == "enplanements", suffix <- "-commercial-service-enplanements.xlsx", suffix <- "-cargo-airports.xlsx")
  filename <- paste0("cy", yearabr, suffix)
  dt <- setDT(read.xlsx(file.path(faa.url.root, filename)))
  dt.clean <- na.omit(dt)
  cat("\n", datatype, "successfully read!\n")
  return(dt.clean)
}

clean.faa.enplanements <- function(year, table) {
  # This function will munge the file read-in
  
  yearabr <- substr(year, 3, 4)
  cols <- c(colnames(table)[2:8], colnames(table)[grep(yearabr, colnames(table))])
  dt <- table[, ..cols][, year := year]
  colnames(dt) <- c("RO", "ST", "Locid", "City", "Airportname", "SL", "Hub", "enplanements", "year")
  dt[, enplanements := as.numeric(enplanements)]

  return(dt)
}