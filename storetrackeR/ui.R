

f7Page(title = "storetracker",
       geoloc::onload_geoloc(),
       f7TabLayout(
           navbar = f7Navbar(title = "Storetracker"),
           f7Tabs(
               f7Tab(tabName = "Login"),
               f7Tab(tabName = "Search Store",
                     f7AutoComplete(inputId = "searchproducts",
                                    label = "Products",
                                    choices = product_choices,
                                    multiple = TRUE),
                     
                     leafletOutput("storemap", height = 200),
                     dataTableOutput("store_rec_table")
               ),
               f7Tab(tabName = "Track Store",
                     f7AutoComplete(inputId = "visited_store",
                                    label = "Store",
                                    choices = c("Schmoll 1", "Schmoll 2", "Schmoll3")),
                     
                     f7Select(inputId = "rate_occupancy",
                              label = "Occupancy",
                              choices = c("leer", "wenig", "normal", "voll")),
                    
                     f7Accordion(
                       create_stock_rater(id = 1),
                       create_stock_rater(id = 2),
                       uiOutput("product_stock")
                      ),
                     
                     actionButton(inputId = "add_product",
                                  label = "add Product")
                     
                     )
           )
        )
           
      
)

