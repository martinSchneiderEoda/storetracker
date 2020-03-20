

library(shiny)
library(shinyMobile)
library(leaflet)
library(DT)

f7Page(title = "storetracker",
       geoloc::onload_geoloc(),
       f7TabLayout(
           navbar = f7Navbar(title = "Storetracker"),
           f7Tabs(
               f7Tab(tabName = "Login"),
               f7Tab(tabName = "Search Store",
                     
                      f7AutoComplete(inputId = "searchproducts",
                                      label = "Products",
                                      choices = c("Bananen", "Klopapier", "Nudeln"),
                                      multiple = TRUE),
                     
                    
                      leafletOutput("storemap"),
                    
                    
                      tableOutput("store_rec_table")
                    
                     ),
               f7Tab(tabName = "Track Store")
           )
           
       )
)
