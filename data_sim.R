library(DBI)
library(sf)
library(forecast)
library(tsibbledata)
library(tidyverse)
library(lubridate)
library(tsibble)
library(osmdata)
library(revgeo)



# Kassel Stores -----------------------------------------------------------
sm_df <- read_delim("supermarkets.csv", delim = "\t", locale = locale(encoding = "ISO-8859-2")) %>% filter(!is.na(geometry))

sm_df <- sm_df %>% 
  select(name, addr.city, addr.housenumber, addr.postcode, addr.street, brand, opening_hours, geometry) %>% 
  mutate(ID = 1:nrow(sm_df), 
         Lon = unlist(str_extract_all(sm_df$geometry, "[0-9]+\\.[0-9]+") %>% lapply("[[",1)), 
         Lat = unlist(str_extract_all(sm_df$geometry, "[0-9]+\\.[0-9]+") %>% lapply("[[",2)), 
         City = "Kassel") %>% 
  rename(Name = name) %>% 
  mutate_at(vars(Lon, Lat), as.numeric) %>% 
  select(-geometry)
  


con <- dbConnect(RSQLite::SQLite(), "storeTrackeDB.sqlite")

dbListTables(con)

dbWriteTable(con, "Supermarket", sm_df, overwrite = TRUE)
dbListTables(con)

res <- dbSendQuery(con, "SELECT * FROM Supermarket")
dbFetch(res)

dbClearResult(res)

# Disconnect from the database


data(vic_elec)

visitors <- tibble(Supermarket_ID = numeric(), Date = as.Date(character()), 
                   Hour = numeric(), Customers = numeric())

for (i in 1:nrow(sm_df)){
  print(i)
  samp_week <- yearweek(sample(seq.Date(as.Date("2012-01-01"), as.Date("2014-12-31"), by = "day"), 1))
  samp_max <- 100 + round(20 * runif(1, -1, 1))
  
  #samp_week <- min(sam)
  if(week(samp_week) == 52) {
    samp_week <- yearweek("2014 W02")
  }
  visitors <- vic_elec %>% 
    as_tibble() %>% 
    mutate(Week = yearweek(Date)) %>% 
    #filter(between(Date, as.Date("2014-03-17"), as.Date("2014-03-23"))) %>% 
    filter(Week == samp_week) %T>% 
    {update_df <<- data.frame(Date = distinct(.,Date) %>% pull(), 
                              NewDate = seq.Date(as.Date("2020-03-16"),as.Date("2020-03-22"), by = "day"))} %>% 
    left_join(update_df, by = "Date") %>% 
    mutate(Date = NewDate, 
           Hour = hour(Time)) %>% 
    select(-NewDate) %>% 
    group_by(Date, Hour) %>% 
    summarize(Demand = sum(Demand)) %>% 
    ungroup(Hour) %>% 
    mutate(Demand = (Demand - min(Demand)) * 100 / diff(range(Demand)),
           Demand = if_else(between(Hour, 8, 20), Demand, 0)) %>%
    ungroup() %>%
    rename(Customers = Demand) %>% 
    mutate(Supermarket_ID = i) %>% 
    bind_rows(visitors, .)
  
}

dbWriteTable(con, "Visitors", visitors %>% 
               mutate(Date = as.POSIXct(Date) + hours(Hour - 1)) %>% 
               mutate_at(vars(Date), as.character) %>% 
               mutate_at(vars(Customers), round) %>% 
               select(-Hour), overwrite = TRUE)

res <- dbSendQuery(con, "SELECT * FROM Visitors WHERE Supermarket_ID = 40")
dbFetch(res)

dbClearResult(res)


# Products ----------------------------------------------------------------
products <- tibble(ID = 1:3, Name = c("Klopapier", "Seife", "Nudeln"))

dbWriteTable(con, "Products", products)

new_products <- read_delim("Lebensmittel.csv", delim = "\t", col_names = FALSE) %>% 
  filter(!X1 %in% c("Nudeln", "Seife", "Bananen", "Toilletenpapier")) %>% 
  rename(Name = X1) %>% 
  mutate(ID = (1:n()) + 4)

dbWriteTable(con, "Products", new_products, append = TRUE)

# Product Capacity --------------------------------------------------------
prod_cap <- expand.grid(Date = seq.POSIXt(as.POSIXct("2020-03-16"),as.POSIXct("2020-03-23"), by = "hour"),
                        Supermarket_ID = 1:nrow(sm_df),
                        Product_ID = 1:4) %>% 
  as_tibble()

prod_cap <- prod_cap %>% 
  mutate(Cap = rnorm(n(), sd = 15)) %>% 
  group_by(Supermarket_ID, Product_ID) %>% 
  mutate(Cap = Cap - min(Cap) * 100 / diff(range(Cap)),
         Cap = if_else(between(hour(Date), 8, 20), round(Cap), 0),
         Date = as.character(Date)) %>% 
  ungroup()

miss_ind <- sample(1:nrow(prod_cap), 800*4*14, replace = TRUE)

dbWriteTable(con, "Stock",  prod_cap %>%
               mutate(Cap = if_else(row_number() %in% miss_ind, as.numeric(NA), Cap)) %>% 
               fill(Cap, .direction = "down"), overwrite = TRUE)

dbDisconnect(con)
