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