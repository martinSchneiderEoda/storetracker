#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    
    output$storemap <- renderLeaflet({
        
        leaflet() %>% 
            addTiles() %>% 
            setView(as.numeric(input$geoloc_lon), as.numeric(input$geoloc_lat), zoom = 17)
    })
    
    output$store_rec_table <- renderTable({
        data.frame(
            Store = c("Schmoll 1", "Schmoll 2", "Schmoll 3"),
            Adresse = c("absesf", "abdssdfs", "fvbsdfe"),
            Auslastung = c("voll", "voll", "leer"),
            Bananen = c("hoch", "niedrig", "mittel"),
            Klopapier = c("leer", "leer", "leer"),
            Nudeln = c("leer", "hoch", "leer"),
            stringsAsFactors = FALSE
        )
    })
})
