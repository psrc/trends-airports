library(data.table)
library(tidyverse)
library(odbc)

dir <- "C:/Users/CLam/Desktop/trends-airports/Data"

elmer_connection <- dbConnect(odbc(),
                              driver = "SQL Server",
                              server = "sql2016\\DSADEV",
                              database = "Sandbox",
                              trusted_connection = "yes"
)


# Initial Data ------------------------------------------------------------


# Initialize Enplanements
compile.faa.enplanements <- function() {
  efiles <- list.files(dir, pattern = "-commercial-service-enplanements.xlsx", full.names = T)
  dts <- NULL
  for (efile in efiles) {
    fileyrabr <- basename(efile) %>% str_extract("\\d+")
    fileyr <- fileyrabr %>% paste0("20", .)
    dt <- read.xlsx(efile) %>% as.data.table
    cols <- c(colnames(dt)[1:8], colnames(dt)[grep(fileyrabr, colnames(dt))])
    dtn <- dt[!is.na(Hub), ..cols][, year := fileyr]
    colnames(dtn) <- c("Rank", "RO", "ST", "Locid", "City", "Airportname", "SL", "Hub", "Enplanements", "Year")
    dtn[, enplanements := as.numeric(enplanements)]
    ifelse(is.null(dts), dts <- dtn, dts <- rbindlist(list(dts, dtn), use.names = T))
  }
  return(dts)
}

# Initialize Cargo
compile.faa.cargo <- function() {
  header.list <- list(Rank = "Rank",
                      Locid = "Locid",
                      RO = c("RO", "FAA.Region"),
                      ST = c("State", "ST"),
                      City = "City",
                      Airportname = "Airport.Name",
                      SL = c("S/L", "Svc Lvl", "Svc.Lvl", "Airport.Category"),
                      Hub = "Hub")
  header.list.flat <- flatten_chr(header.list)
  efiles <- list.files(dir, pattern = "-cargo-airports.xlsx", full.names = T)
  dts <- NULL
  for (efile in efiles) {
    fileyrabr <- basename(efile) %>% str_extract("\\d+")
    fileyr <- fileyrabr %>% paste0("20", .)
    dt <- read.xlsx(efile) %>% as.data.table
    # select colnames in headerlist and rename
    oldcols <- c(colnames(dt)[colnames(dt) %in% header.list.flat], colnames(dt)[str_which(colnames(dt), paste0(".*", fileyrabr, ".*Landed\\.Weight"))])
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
    setnames(dt, oldcols, newcols)
    trimcols <- c("Locid", "RO", "ST", "City", "Airportname", "SL", "Hub")
    dtn <- dt[!is.na(Hub), ..newcols
              ][, `:=` (year = fileyr,
                        Rank = str_trim(Rank) %>% as.numeric,
                        landed_weight = str_replace_all(landed_weight, ",", "") %>% str_trim %>% as.numeric)
                ][, (trimcols) := mapply(function(x) str_trim(.SD[[x]]), trimcols, SIMPLIFY = F)]
    
    ifelse(is.null(dts), dts <- dtn, dts <- rbindlist(list(dts, dtn), use.names = T))
  }
  return(dts)
}

# dt <- compile.faa.enplanements()
# dbWriteTable(elmer_connection, "faa_enplanements", as.data.frame(dt))

# dt <- compile.faa.cargo()
# dbWriteTable(elmer_connection, "faa_cargo", as.data.frame(dt))

dbDisconnect(elmer_connection)


# Append New Data ---------------------------------------------------------


