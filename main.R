library(tidyverse)
library(rvest)
library(lubridate)

# Setup
force_dl <- FALSE
dl_src <- "http://www.aos.wisc.edu/~sco/lakes/Mendota-ice.html"
dl_file <- "data/raw_lake_mendota.html"

if(!file.exists(dl_file) | force_dl) {
  download.file(dl_src, dl_file)
}

# Read file and discard useless indices
lake_lines <- read_html(dl_file) %>% 
  html_nodes("td font") %>% 
  html_text() %>% 
  str_trim() %>% 
  keep(function(x) !(x %in% c("", "WINTER", "CLOSED", "OPENED", "DAYS")))

get_lines <- function(i) lake_lines[(1:32 %% 4) == i]

# Extract data from text
years <- get_lines(1) %>%
  str_extract_all("([0-9]{4}(?=(-[0-9]{2})))|\"") %>% 
  flatten_chr()

day_month  <- .  %>% 
  str_extract_all("([0-9]{1,2} [A-Z]{1}[a-z]{2})|---" ) %>% 
  flatten_chr()
  
closed <- get_lines(2) %>% 
  day_month()

opened <- get_lines(3) %>% 
  day_month()

days <- get_lines(0) %>% 
  str_extract_all("((?<![0-9])[0-9]{1,3}(?![0-9]))|---|--|-") %>% 
  flatten_chr()

# Compute dates and number of days
ydm2 <- function(y, d) ydm(paste(y, d))

lake_mendota <- tibble(
  year = as.integer(years),
  closed = closed,
  opened = opened
) %>% 
  mutate(
    year = if_else(is.na(year), lag(year), year),
    # Arbitraty Choice of August 30
    season_start = ydm2(year, "30 August"),
    date_closed = if_else(ydm2(year, closed) >= season_start, 
      true = ydm2(year, closed), 
      false = ydm2(year + 1, closed)
    ),
    date_opened = if_else(ydm2(year, opened) >= season_start, 
      true = ydm2(year, opened), 
      false = ydm2(year + 1, opened)
    ),
    days = as.integer(date_opened - date_closed),
    start_day =  as.integer(date_closed - season_start),
    end_day = as.integer(date_opened - season_start)
  )

# Discarding 1852 - 1854
lake_mendota <- filter(lake_mendota, year > 1854)

# Save data
write_csv(lake_mendota, "data/lake_mendota.csv")

# Render Website
rmarkdown::render("index.Rmd", output_file = "index.html", output_dir = "docs")
