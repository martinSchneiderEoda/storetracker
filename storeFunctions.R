get_customers <- function(sm_id, date, full_day = TRUE) {
  current_ts <- Sys.time()
  
  if(length(sm_id) > 1) {
    full_day <- FALSE
  }
  
  if(full_day){
    all_dates <- seq(as.POSIXct(lubridate::date(date)), length.out = 24, by = "hours")
  } else {
    all_dates <- date
  }
  
  result_df <- tibble(Date = as.POSIXct(character()),
                      Customers = numeric(),
                      Supermarket_ID = numeric())
  
  for(tmp_date in all_dates) {
    stock_df <- tbl(con, "Visitors") %>%
      filter(Supermarket_ID %in% sm_id) %>% 
      collect() %>% 
      mutate_at(vars(Date), as.POSIXct) %>% 
      filter(Date <= current_ts) %>% 
      mutate(Day = lubridate::date(Date),
             Hour = hour(Date)) %>% 
      group_by(Supermarket_ID, Day, Hour) %>% 
      summarize(Customers = mean(Customers)) %>% 
      ungroup() %>% 
      mutate(Date = as.POSIXct(Day) + hours(Hour)) 
    
    if (tmp_date <= current_ts) {
      result_df <-  stock_df %>% 
        select(-Day, -Hour) %>% 
        filter(Date <= as.POSIXct(tmp_date, origin = "1970-01-01")) %>% 
        arrange() %>% 
        group_by(Supermarket_ID) %>% 
        slice(n()) %>% 
        ungroup() %>% 
        bind_rows(result_df, .)
      
    } else {
      result_df <- stock_df %>% 
        filter(Hour == hour(as.POSIXct(tmp_date, origin = "1970-01-01"))) %>% 
        group_by(Supermarket_ID) %>% 
        summarize(Customers = round(mean(Customers))) %>% 
        ungroup() %>% 
        mutate(Date = as.POSIXct(tmp_date, origin = "1970-01-01")) %>% 
        bind_rows(result_df, .)
    }
  }
  
  if(full_day){
    result_df <- result_df %>% 
      select(-Supermarket_ID)
  } 
  
  return(result_df %>% 
           mutate_if(is.numeric, round))
}

get_auslastung <- function(sm_ID, date) {
  customers <- get_customers(sm_ID = sm_ID, date = date) %>% 
    mutate(Auslastung = case_when(Customers == 0 ~ "Closed",
                                  Customers <= 70 ~ "Low",
                                  Customers >= 90 ~ "High",
                                  TRUE ~ "Medium")) %>% 
    filter(Date == date) %>% 
    #rowwise() %>% 
    mutate(Date = as.POSIXct(Date) + hours(Hour)) %>% 
    #ungroup() %>% 
    select(Date, Auslastung)
  
  return(customers)  
}

get_products <- function() {
  res <- dbSendQuery(con, "SELECT * FROM Products")
  
  df <- dbFetch(res)
  
  dbClearResult(res)
  
  return(df)
}


add_product <- function(name) {
  res <- dbSendQuery(con, "SELECT COUNT(1) FROM Products")
  n_products <- dbFetch(res)
  dbClearResult(res)
  
  res <- dbSendQuery(con, paste0("INSERT INTO Products (ID, Name) VALUES (", 
                                 n_products + 1, ", '", name, "')"))
  
  dbClearResult(res)
}



# get_product_stock <- function(sm_id, product_id, date) {
#   res <- dbSendQuery(con, paste0("SELECT * FROM Stock WHERE Supermarket_ID = ", 
#                                  sm_id, " AND Product_ID = ", product_id))
#   df <- dbFetch(res) 
#   dbClearResult(res)
#  
#   return(df %>% 
#            mutate(Date = as.POSIXct(Date)) %>% 
#            filter(lubridate::date(Date) == date))
# 
# }


update_product_stock <- function(sm_id, product_id, date, capacity) {
 
  df <- data.frame(
    Date = date,
    Supermarket_ID = sm_id,
    Product_ID = product_id,
    Cap = capacity,
    stringsAsFactors = FALSE
  )
  dbSendQuery(con, 'INSERT INTO Stock (Date, Supermarket_ID, Product_ID, Cap) VALUES (:Date, :Supermarket_ID, :Product_ID, :Cap);', df)
}

update_visitors <- function(sm_id, date, hour, cap) {
  
  df <- data.frame(
    Date = date,
    Supermarket_ID = sm_id,
    Customers = cap
    )
  
  dbSendQuery(con, 'INSERT INTO Visitors (Supermarket_ID, Date, Customers) VALUES (:Supermarket_ID, :Date, :Customers);', df)
  
  
}
  

get_product_stock <- function(sm_id, product_id, date, full_day = FALSE) {
  
  current_ts <- Sys.time()
  
  if(full_day){
    all_dates <- seq(as.POSIXct(lubridate::date(date)), length.out = 24, by = "hours")
  } else {
    all_dates <- as.POSIXct(date)
  }
  
  result_df <- tibble(Date = as.POSIXct(character()),
                      Supermarket_ID = numeric(),
                      Product_ID = numeric(),
                      Cap = numeric())
  
  for(tmp_date in all_dates) {
    stock_df <- tbl(con, "Stock") %>%
      filter(Product_ID %in% product_id & Supermarket_ID %in% sm_id) %>% 
      collect() %>% 
      mutate_at(vars(Date), as.POSIXct) %>% 
      filter(Date <= current_ts) %>% 
      mutate(Day = lubridate::date(Date),
             Hour = hour(Date)) %>% 
      group_by(Day, Hour, Supermarket_ID, Product_ID) %>% 
      summarize(Cap = mean(Cap)) %>% 
      ungroup() %>% 
      mutate(Date = as.POSIXct(Day) + hours(Hour)) 
    
    if (tmp_date <= current_ts) {
      
      result_df <-  stock_df %>% 
        select(-Day, -Hour) %>% 
        filter(Date <= as.POSIXct(tmp_date, origin = "1970-01-01")) %>% 
        arrange() %>% 
        group_by(Supermarket_ID, Product_ID) %>% 
        slice(n()) %>% 
        ungroup() %>% 
        bind_rows(result_df, .)
      
    } else {
      
      result_df <- stock_df %>% 
        filter(Hour == hour(as.POSIXct(tmp_date, origin = "1970-01-01"))) %>% 
        group_by(Supermarket_ID, Product_ID) %>% 
        summarize(Cap = round(mean(Cap))) %>% 
        ungroup() %>% 
        mutate(Date = as.POSIXct(tmp_date, origin = "1970-01-01")) %>% 
        bind_rows(result_df, .)
    }
  }
  
  if(!full_day){
    result_df <- result_df %>% 
      select(-Date)
  }
  
  return(result_df)
}

get_nearby_markets <- function(geoloc_lon, geoloc_lat, searchradio) {
  req(geoloc_lon)
  req(geoloc_lat)
  
  markets <- tbl(con, "Supermarket") %>% 
    collect()
  
  current_location <- c(geoloc_lon,
                        geoloc_lat)
  
  rad = as.numeric(searchradio)
  
  coord_df <- data.frame(markets, 
                         distance = geosphere::distHaversine(
                           markets %>% select(Lon, Lat) %>% mutate_all(as.numeric),
                           current_location) / 1000) %>% 
    mutate(nearby =  distance < rad)  
  
  return(coord_df)
}