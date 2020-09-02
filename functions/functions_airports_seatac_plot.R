library(plotly)

source(here::here("functions", "functions_airports_seatac.R"))

# ggplot standard formatting
text.size <- 10
font.family <- list(family = "Segoe UI Semilight")
o <- list(theme(axis.text.x = element_text(size=text.size,
                                           angle = 45,
                                           vjust = 0.5,
                                           hjust=.5),
                axis.text.y = element_text(size=text.size),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                legend.text=element_text(size=text.size),
                legend.title = element_text(size=text.size)))

every_nth <-  function(n) {
  # returns every other element in vector
  return(function(x) {x[c(TRUE, rep(FALSE, n - 1))]})
}

line.plot.seatac.pco <- function(categories = "all", vectorize.args = "t") {
  # this line plot will graph all years by month
  
  facet.var <- "group_label"
  
  dt <- read.seatac.pco() %>% summarise.main.types.pco("month")
  
  ifelse(categories == "all", dt, dt <- dt[get(eval(facet.var)) %in% categories, ])
  
  g <- ggplot(dt, aes(x = month_abr, y = estimate)) +
    geom_line(aes(group = year, color = year)) +
    scale_y_continuous(labels=scales::comma) +
    scale_color_discrete(name="Year") +
    scale_x_discrete(breaks = every_nth(n = 2))
  f <- facet_wrap(vars(.data[[facet.var]]), scales = "free_y") 
  p <- g + f + o
  return(ggplotly(p) %>% layout(font = font.family))
}

bar.plot.seatac.pco <- function(categories = "all", vectorize.args = "t") {
  # this bar graph will plot the latest and next most recent years' data by month
  
  facet.var <- "group_label"
  
  dt <- read.seatac.pco() %>% summarise.main.types.pco("month")
  t <- dt[, year_num := as.numeric(as.character(year))
          ][year_num %in% c((max(year_num)-1), max(year_num)), 
            ][, year := factor(year, levels = c((max(year_num)-1), max(year_num)))]
  
  ifelse(categories == "all", t, t <- t[get(eval(facet.var)) %in% categories, ])
    
  # set colors
  mycolors <- c("grey", "purple")
  names(mycolors) <-  levels(t$year)
  
  g <- ggplot(t) +
    geom_col(aes(x = month_abr, y = estimate, color = year, fill = year, group = year), 
             width = .7, position = "dodge") + 
    scale_color_manual(name = "Year", values = mycolors) +
    scale_fill_manual(name = "Year", values = mycolors) +
    scale_y_continuous(labels=scales::comma) +
    scale_x_discrete(breaks = every_nth(n = 2))
  f <- facet_wrap(vars(.data[[facet.var]]), scales = "free_y") 
  p <- g + f + o
  return(ggplotly(p) %>% layout(font = font.family))
}