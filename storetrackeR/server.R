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
        rv$nearbystores = c(rv$nearbystores, "Schmoll 1", "Schmoll 2", "Schmoll 3")
    })
    observe({
        output$visited_store <- renderUI({
            f7AutoComplete(inputId = "visited_store",
                           label = "Store",
                           choices = rv$nearbystores)
        })
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
