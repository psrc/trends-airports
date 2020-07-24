library(data.table)
library(tidyverse)
library(DBI)
library(odbc)
# library(readxl)
# library(plotly)
# library(openxlsx)

category.dict <- c("passengers" = "all passengers",
                   "domestic passengers" ="domestic passengers",
                   "international passengers" = "international passengers",
                   "cargo" = "all cargo",
                   "air freight" = "all freight cargo",
                   "domestic air freight" = "domestic freight cargo",
                   "international air freight" = "international freight cargo",
                   "air mail" = "mail cargo",
                   "operations" = "operations")

db.connect <- function(adatabase) {
  elmer_connection <- dbConnect(odbc(),
                                driver = "SQL Server",
                                server = "AWS-PROD-SQL\\COHO",
                                database = adatabase,
                                trusted_connection = "yes"
  )
}

read.dt <- function(adatabase, atable) {
  # read a table from the SQL Server database
  elmer_connection <- db.connect(adatabase)
  dtelm <- dbReadTable(elmer_connection, SQL(atable))
  dbDisconnect(elmer_connection)
  setDT(dtelm)
}

read.seatac.pco <- function() {
  dt <- read.dt("Elmer", "seatac_airport.v_measurements")
  dt[, measurement_date := as.Date(measurement_date)]
  return(dt)
}

summarise.main.types.pco <- function(atable, aggregate.by = c("month", "year")) {
  dt <- copy(atable)
  date.field <- "measurement_date"
  group.cols <- paste0("type_group_", 1:3)
  sum.dt <- NULL
  
  for (group.col in group.cols) {
    if (group.col == "type_group_1") {
      # group 1: dom + intl pass, dom + intl freight
      t <- dt[str_detect(get(eval(group.col)), ".*passengers$")|str_detect(get(eval(group.col)), ".*freight$"),
              .(estimate = sum(value)), by = .(month(get(eval(date.field))), year(get(eval(date.field))), group = get(eval(group.col)))]
      
    } else if (group.col == "type_group_2") {
      # group 2: mail, freight
      t <- dt[str_detect(get(eval(group.col)), ".*mail$")|str_detect(get(eval(group.col)), ".*freight$"),
              .(estimate = sum(value)), by = .(month(get(eval(date.field))), year(get(eval(date.field))), group = get(eval(group.col)))]
      
    } else {
      # group 3: grand total
      t <- dt[, .(estimate = sum(value)), by = .(month(get(eval(date.field))), year(get(eval(date.field))), group = get(eval(group.col)))]
    }
    ifelse(is.null(sum.dt), sum.dt <- t, sum.dt <- rbindlist(list(sum.dt, t), use.names = T))
  }
  
  # add month.abb and other column details
  sum.dt$month_abr <- factor(month.abb[sum.dt$month], levels = month.abb)
  sum.dt$year <- factor(sum.dt$year, levels = sort(unique(sum.dt$year)))
  sum.dt <- sum.dt[order(year, month)]
  sum.dt$group_label <- category.dict[sum.dt$group]
  
  # clean up/sum and return
  if (aggregate.by == "month") {
    excl.cols.month <- c("month", "group")
    sum.dt <- sum.dt[, (excl.cols.month) := NULL]
    sum.dt <- setcolorder(sum.dt, c("group_label", "month_abr", "year", "estimate"))
    return(sum.dt)
  } else if (aggregate.by == "year") {
    sum.dt <- sum.dt[, lapply(.SD, sum), .SDcols = "estimate", by = .(group_label, year)]
    return(sum.dt)
  }

} 


# Test --------------------------------------------------------------------


adt <- read.seatac.pco()
adt.types.test <- summarise.main.types.pco(adt, "year")
adt.types.test2 <- summarise.main.types.pco(adt, "month")
