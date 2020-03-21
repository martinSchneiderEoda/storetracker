get_customers <- function(sm_ID, date = NULL, hour = NULL) {
  res <- dbSendQuery(con, 
                     paste0("SELECT * FROM Visitors WHERE Supermarket_ID = ", sm_ID))
  
  df <- dbFetch(res)
  
  dbClearResult(res)
  
  if(!is.null(date)) {
    df <- df %>% 
      filter(Date == date)
  }
  
  if(!is.null(hour)) {
    df <- df %>% 
      filter(Hour == hour)
  }
  
  return(df)
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

get_product_stock <- function(sm_id, product_id, date) {
  res <- dbSendQuery(con, paste0("SELECT * FROM Stock WHERE Supermarket_ID = ", 
                                 sm_id, " AND Product_ID = ", product_id))
  df <- dbFetch(res) 
  dbClearResult(res)
 
  return(df %>% 
           mutate(Date = as.POSIXct(Date)) %>% 
           filter(lubridate::date(Date) == date))

}