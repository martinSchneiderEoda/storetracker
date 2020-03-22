#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    # add new produt to rater ---------------------------------------------
    products <- reactiveValues(ind = c(1))
    
    observeEvent(input$add_product,{
       products$ind <- c(products$ind, max(products$ind)+1)
    })
    
    observe({
        output$product_stock <- renderUI({
            # Create rows
            items <- lapply(products$ind,function(i){
                create_stock_rater(id = i)
            })
            do.call(shiny::tagList,items)
            
        })
    })
    
    # write user input in db --------------------------------------------------
    observeEvent(input$submit_stock, {
       
        ind <- str_subset(names(input), "select_product")
        
        lapply(ind,
               function(x) {
                   
                   cap_input <- str_replace_all(x, 
                                                pattern = "select_",
                                                replacement = "stock_")
                  
                  
                   update_product_stock(sm_id = stores[input$visited_store],
                                        product_id =  product_choices[input[[x]]],
                                        date = as.character(Sys.time()),
                                        capacity = input[[cap_input]])
                  
        })
        
        update_visitors(sm_id = stores[input$visited_store],
                        date = as.character(Sys.time()),
                        cap = input$rate_occupancy)
        
    })

    # nearby stores -----------------------------------------------------------
    rv <- reactiveValues(nearbystores = data.frame(ID = numeric(), Name = character(), 
                                                   distance = numeric()))
    
    observe({
        
        req(input$geoloc_lon)
        req(input$geoloc_lat)
        
        coord_df <- get_nearby_markets(geoloc_lon = input$geoloc_lon,
                                       geoloc_lat = input$geoloc_lat,
                                       searchradio = input$searchradio)
        
        
        rv$nearbystores <- coord_df %>% 
                filter(nearby) %>% 
                select(ID, Name, distance) %>% 
                mutate_at(vars(distance), ~round(.,2))

    })
    
    observe({
        output$visited_storeU <- renderUI({
            f7AutoComplete(inputId = "visited_store",
                           label = "Store",
                           choices = rv$nearbystores$Name)
        })
    })
    

    store_capacity_df <- reactive({
        get_customers(sm_id = tbl(con, "Supermarket") %>% 
                          as_tibble() %>% 
                          filter(Name == input$capacity_store) %>% 
                          pull(ID), 
                      date = input$capacity_date)
    })
    
    product_stock_df <- reactive({
        prod_id <- get_products() %>% 
            filter(Name == input$stock_product) %>% 
            pull(ID)
        
        get_product_stock(sm_id = tbl(con, "Supermarket") %>% 
                              as_tibble() %>% 
                              filter(Name == input$capacity_store) %>% 
                              pull(ID), 
                          product_id = prod_id,
                          date = input$capacity_date,
                          full_day = TRUE) 
    })
    
    output$store_capacity_plot <- renderPlot({
        ggplot(store_capacity_df() %>% 
                   filter(between(hour(Date), 9, 20)) %>% 
                   mutate(Predicted = Date > round(Sys.time(), "hour")), 
               aes(x = Date, y = Customers)) +
            geom_bar(stat = "identity", aes(fill = Predicted)) +
            scale_fill_manual(breaks = c("FALSE", "TRUE"),
                              labels = c("Recorded", "Predicted"), 
                              values = c("FALSE" = "black", "TRUE" = "darkgrey"), 
                              drop = FALSE,
                              name = NULL) +
            ylim(c(0,100)) +
            xlab("Uhrzeit") +
            ggtitle("Kundenauslastung") +
            ylab("") +
            theme_minimal()
    })
    
    output$product_stock_plot <- renderPlot({
        ggplot(product_stock_df() %>% 
                   filter(between(hour(Date), 9, 20)) %>% 
                   mutate(Predicted = Date > round(Sys.time(), "hour")), 
               aes(x = Date, y = Cap)) +
            geom_bar(stat = "identity", aes(fill = Predicted)) +
            scale_fill_manual(breaks = c("FALSE", "TRUE"),
                              labels = c("Recorded", "Predicted"), 
                              values = c("FALSE" = "black", "TRUE" = "darkgrey"), 
                              drop = FALSE,
                              name = NULL) +
            theme(legend.title = element_blank()) +
            ylim(c(0,100)) + 
            xlab("Uhrzeit") +
            ggtitle("Produktverfügbarkeit") +
            ylab("") +
            theme_minimal()
    })
    
    # map ------------------------------------------------------------------
    output$storemap <- renderLeaflet({
        
        
        req(input$geoloc_lon)
        req(input$geoloc_lat)
        
        coord_df <- get_nearby_markets(geoloc_lon = input$geoloc_lon,
                                       geoloc_lat = input$geoloc_lat,
                                       searchradio = input$searchradio)
        
        markets <- coord_df %>% 
            filter(nearby)
        
        
        markets$prio <- sample(c("gering", "mittel", "hoch"), size = nrow(markets),
                               replace = TRUE, prob = c(0.7, 0.2, 0.1))
        
        
        
        getColor <- function(markets) {
            sapply(markets$prio, function(prio) {
                print(prio)
                if(prio == "hoch") {
                    "green"
                } else if(prio == "mittel") {
                    "orange"
                } else {
                    "red"
                } })
        }
        
        icons <- awesomeIcons(
            icon = "shopping-cart",
            iconColor = 'black',
            library = 'fa',
            markerColor = getColor(markets)
        )
        
        icons$markerColor <- as.character(icons$markerColor)
        
        
        
        leaflet() %>%
            addTiles() %>%
            setView(as.numeric(input$geoloc_lon), as.numeric(input$geoloc_lat), zoom = 14) %>%
            addAwesomeMarkers(lng = as.numeric(markets$Lon),
                              lat = as.numeric(markets$Lat), icon=icons,
                              label = markets$Name)
            #addMarkers(lng = as.numeric(markets$Lon), lat = as.numeric(markets$Lat))
        
        
    })
    
    # store table ------------------------------------------------------------
    output$store_rec_table <- renderDataTable({
        
        wanted_products_ids <- input$searchproducts
        nearby_stores_ids <- rv$nearbystores$ID
        
        wanted_date <- as.POSIXct(input$searchdate) + hours(input$searchhour)
 
        wanted_store_cap <- get_product_stock(sm_id = nearby_stores_ids, 
                                              product_id = wanted_products_ids,
                                              date = wanted_date)


        wanted_store_cap <- left_join(wanted_store_cap, rv$nearbystores,
                                      by = c("Supermarket_ID" = "ID")) %>%
            rename(Supermarket_Name = Name)

        product_names <- tbl(con, "Products") %>%
            filter(ID %in% wanted_products_ids) %>%
            collect()
      
        wanted_store_cap <- left_join(wanted_store_cap, product_names,
                                      by = c("Product_ID" = "ID")) %>%
            rename(Product_Name = Name)

        wanted_store_cap %>%
            select(-Product_ID) %>%
            pivot_wider(names_from = Product_Name,
                        values_from = Cap) %>% 
            ungroup() %>% 
            mutate(Occupancy = get_customers(sm_id = Supermarket_ID, 
                   date = wanted_date, full_day = FALSE)$Customers) %>% 
            select(-Supermarket_ID) %>% 
            mutate(scaled_distance = 100 - (distance * 100 / as.numeric(input$searchradio)),
                   transformed_occ = 100 - Occupancy) %T>%
            {score <<- select(., -Supermarket_Name, -Occupancy, -distance) %>% 
                rowSums()} %>% 
            mutate(Score = round(score / (nrow(product_names) + 2))) %>% 
            arrange(desc(Score)) %>% 
            select(-scaled_distance, -transformed_occ) %>% 
            rename(Markt = "Supermarket_Name",
                   "Distance [KM]" = distance) %>% 
            datatable(options = list(dom = "t",
                                     scrollX = TRUE),
                      rownames = FALSE)
    })
})
