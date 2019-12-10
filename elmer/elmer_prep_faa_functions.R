library(tidyverse)

db.connect <- function(adatabase) {
  # connect to the SQL server
  elmer_connection <- dbConnect(odbc(),
                                driver = "SQL Server",
                                server = "AWS-PROD-SQL\\COHO",
                                database = adatabase,
                                trusted_connection = "yes"
  )
}

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

clean.faa.cargo <- function(year, table) {
  # This function will munge the file read-in
  
  t <- copy(table)
  header.list <- list(Locid = "Locid",
                      RO = c("RO", "FAA.Region"),
                      ST = c("State", "ST"),
                      City = "City",
                      Airportname = "Airport.Name",
                      SL = c("S/L", "Svc Lvl", "Svc.Lvl", "Airport.Category"),
                      Hub = "Hub")
  header.list.flat <- flatten_chr(header.list)
  
  yearabr <- substr(year, 3, 4)

  # select colnames in headerlist and rename if necessary
  oldcols <- c(colnames(t)[colnames(t) %in% header.list.flat], colnames(t)[str_which(colnames(t), paste0(".*", yearabr, ".*Landed\\.Weight"))])
  newcols <- c()
  for (i in 1:(length(oldcols)-1)) {
    does.exist <- map(header.list, ~has_element( .x, oldcols[i]))
    does.exist.flat <- flatten_lgl(does.exist)
    if (any(does.exist.flat)) {
      newcol <- names(header.list)[which(does.exist == T)]
      newcols <- c(newcols, newcol)
    }
  }
  newcols <- c(newcols, "landed_weight")
  setnames(t, oldcols, newcols)
  trimcols <- c("Locid", "RO", "ST", "City", "Airportname", "SL", "Hub")
  dt.clean <- t[, ..newcols
            ][, `:=` (year = year,
                      landed_weight = str_replace_all(landed_weight, ",", "") %>% str_trim %>% as.numeric)
              ][, (trimcols) := mapply(function(x) str_trim(.SD[[x]]), trimcols, SIMPLIFY = F)]
  return(dt.clean)
}