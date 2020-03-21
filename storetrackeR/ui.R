

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
                   
                     uiOutput("visited_store"),
                     
                     f7Slider(inputId = "rate_occupancy",
                              label = "Occupancy",
                              min = 0,
                              max = 100,
                              value = 50),
                     
                    f7Accordion(
                       uiOutput("product_stock")
                      ),
                     
                     actionButton(inputId = "add_product",
                                  label = "add Product")
                     
                     )
           )
        )
)

