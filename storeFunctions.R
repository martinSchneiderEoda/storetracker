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

