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
    products <- reactiveValues(ind = c(1, 2))
    
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
    


    # nearby stores -----------------------------------------------------------
    rv <- reactiveValues(nearbystores = c("Arsch of"))
    
    observeEvent(input$geoloc_lon, {
        
        
        markets <- tbl(con, "Supermarket") %>% 
            collect()
        
        current_location <- c(input$geoloc_lon,
                              input$geoloc_lat)
        
        dist = 0.5
        
        coord_df <- data.frame(markets, 
                               nearby = geosphere::distHaversine(
                                   markets %>% select(Lon, Lat), 
                                   current_location
                               ) / 1000 < dist)    
        
        rv$nearbystores <- coord_df %>% 
                filter(nearby) %>% 
                mutate(unique_ind = paste(Name, ID)) %>% 
                pull(unique_ind)
    })
    
    observe({
        output$visited_store <- renderUI({
            f7AutoComplete(inputId = "visited_store",
                           label = "Store",
                           choices = rv$nearbystores)
        })
    })
    

    store_capacity_df <- reactive({
        get_customers(sm_ID = input$capacity_store, date = input$capacity_date) %>% 
            mutate(Date = as.POSIXct(Date) + hours(Hour))
    })
    
    product_stock_df <- reactive({
        prod_id <- get_products() %>% filter(Name == input$stock_product) %>% pull(ID)
        get_product_stock(sm_id = input$capacity_store, 
                          product_id = prod_id,
                          date = input$capacity_date) %>% 
            mutate(Date = as.POSIXct(Date))
    })
    
    output$store_capacity_plot <- renderPlot({
        ggplot(store_capacity_df(), aes(x = Date, y = Customers)) +
            geom_bar(stat = "identity") +
            ylim(c(0,100))
    })
    
    output$product_stock_plot <- renderPlot({
        ggplot(product_stock_df(), aes(x = Date, y = Cap)) +
            geom_bar(stat = "identity") +
            ylim(c(0,100))
    })

    store_capacity_df <- reactive({
        get_customers(sm_ID = input$capacity_store, date = input$capacity_date) %>% 
            mutate(Date = as.POSIXct(Date) + hours(Hour))
    })
    
    product_stock_df <- reactive({
        prod_id <- get_products() %>% filter(Name == input$stock_product) %>% pull(ID)
        get_product_stock(sm_id = input$capacity_store, 
                          product_id = prod_id,
                          date = input$capacity_date) 
    })
    
    output$store_capacity_plot <- renderPlot({
        ggplot(store_capacity_df(), aes(x = Date, y = Customers)) +
            geom_bar(stat = "identity") +
            ylim(c(0,100)) +
            xlab("Uhrzeit") +
            ggtitle("Kundenauslastung") +
            ylab("") +
            theme_minimal()
    })
    
    output$product_stock_plot <- renderPlot({
        ggplot(product_stock_df(), aes(x = Date, y = Cap)) +
            geom_bar(stat = "identity") +
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
        leaflet() %>% 
            addTiles() %>%
            setView(as.numeric(input$geoloc_lon), as.numeric(input$geoloc_lat), zoom = 17)
    })
    
    # store table ------------------------------------------------------------
    output$store_rec_table <- renderDataTable(
        data.frame(
            Store = c("Schmoll 1", "Schmoll 2", "Schmoll 3"),
            Auslastung = c("voll", "voll", "leer"),
            Bananen = c("hoch", "niedrig", "mittel"),
            Klopapier = c("leer", "leer", "leer"),
            Nudeln = c("leer", "hoch", "leer"),
            stringsAsFactors = FALSE
        ) %>% 
            datatable(options = list(dom = "t",
                                     scrollX = TRUE),
                      rownames = FALSE)
    )
})
