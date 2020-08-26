library(data.table)
library(tidyverse)
library(DBI)
library(odbc)
library(openxlsx)

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
                                server = "AWS-PROD-SQL\\SOCKEYE",
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

export.excel.pco <- function(outdir = 'output') {
  if (outdir == 'output') {
    cat("Excel file will be exported to default output subdirectory")
  } else {
    cat("Excel file will be exported to ", outdir)
  }
  
  categories <- unname(category.dict[category.dict != 'operations'])
  dt <- read.seatac.pco() %>% summarise.main.types.pco("month")
  dt.tot <- dt[group_label != 'operations', lapply(.SD, sum), .SDcols = c("estimate"), by = c("year", "group_label")
     ][, month_abr := 'Total'] 
  dt.all <- rbindlist(list(dt, dt.tot), use.names=TRUE)
  setnames(dt.all, c("group_label", "month_abr"), c("Group", "Month"))
  
  dt.cast <- dcast.data.table(dt.all, Group + Month ~ paste0("cy", year), value.var = 'estimate')
  dt.list <- map(categories, ~dt.cast[Group == .x, ])
  names(dt.list) <- lapply(categories, function(x) str_replace_all(x, " ", "_"))
  
  newfilenm <- "Airport_Passenger_Cargo_Counts_"
  wb <- createWorkbook()
  for (d in 1:length(dt.list)) {
    addWorksheet(wb, names(dt.list)[d])
    modifyBaseFont(wb, fontSize = 10, fontName = "Segoe UI Semilight")
    num <- createStyle(numFmt = "#,##0")
    writeData(wb, names(dt.list)[d], dt.list[[d]])
    addStyle(wb, names(dt.list)[d],
             style = num,
             cols = str_which(colnames(dt.list[[d]]), "^cy\\d+"),
             rows = c(2:(nrow(dt.list[[d]])+1)), gridExpand = T, stack = T)
    saveWorkbook(wb, file = file.path(outdir, paste0(newfilenm, Sys.Date(), ".xlsx")), overwrite = T)
  }
  cat("\nData exported to excel\n")
}

# Test --------------------------------------------------------------------


# adt <- read.seatac.pco()
# adt.types.test <- summarise.main.types.pco(adt, "year")
# adt.types.test2 <- summarise.main.types.pco(adt, "month")
# export.excel.pco()
