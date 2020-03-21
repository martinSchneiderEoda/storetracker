library(DBI)
library(sf)
library(forecast)
library(tsibbledata)
library(lubridate)
library(tsibble)

sm_df <- tibble(ID = 1:800, Name = if_else(is.na(cinema$osm_points$name), "", cinema$osm_points$name), 
                Lon = st_coordinates(st_centroid(cinema$osm_points$geometry))[,1], 
                Lat = st_coordinates(st_centroid(cinema$osm_points$geometry))[,2], City = "Kassel")

con <- dbConnect(RSQLite::SQLite(), "storeTrackeDB.sqlite")

dbListTables(con)

dbWriteTable(con, "Supermarket", sm_df)
dbListTables(con)

res <- dbSendQuery(con, "SELECT * FROM Supermarket")
dbFetch(res)

dbClearResult(res)

# Disconnect from the database


data(vic_elec)

visitors <- tibble(Supermarket_ID = numeric(), Date = as.Date(character()), 
                   Hour = numeric(), Customers = numeric())

for (i in 1:800){
  print(i)
  samp_week <- yearweek(sample(seq.Date(as.Date("2012-01-01"), as.Date("2014-12-31"), by = "day"), 1))
  samp_max <- 100 + round(20 * runif(1, -1, 1))
  
  
  visitors <- vic_elec %>% 
    as_tibble() %>% 
    mutate(Week = yearweek(Date)) %>% 
    #filter(between(Date, as.Date("2014-03-17"), as.Date("2014-03-23"))) %>% 
    filter(Week == samp_week) %>% 
    mutate(Hour = hour(Time)) %>% 
    group_by(Date, Hour) %>% 
    summarize(Demand = sum(Demand),
              Time = min(Time)) %>% 
    ungroup() %>% 
    mutate(Demand = Demand * 100 / max(Demand),
           Demand = if_else(between(Hour, 8, 20), Demand, 0)) %>% 
    select(-Time) %>% 
    rename(Customers = Demand) %>% 
    mutate(Supermarket_ID = i) %>% 
    bind_rows(visitors, .)
  
}

dbWriteTable(con, "Visitors", visitors)

res <- dbSendQuery(con, "SELECT * FROM Visitors WHERE Supermarket_ID = 40")
dbFetch(res)

dbClearResult(res)


products <- tibble(ID = 1:3, Name = c("Klopapier", "Seife", "Nudeln"))

dbWriteTable(con, "Products", products)

res <- dbSendQuery(con, "SELECT * FROM Products")
dbFetch(res)

dbClearResult(res)

dbDisconnect(con)
