

f7Page(title = "storetracker",
       geoloc::onload_geoloc(),
       f7TabLayout(
           navbar = f7Navbar(title = "Storetracker"),
           f7Tabs(
               f7Tab(tabName = "Login"),
               f7Tab(tabName = "Store Capacity",
                     f7Select(inputId = "capacity_store",
                              label = "Store ID",
                              choices = store_choices),
                     f7DatePicker(inputId = "capacity_date",
                                  label = "Date",
                                  min = "2020-03-16",
                                  max = "2020-03-22",
                                  value = "2020-03-18"),
                     plotOutput("store_capacity_plot"),
                     f7Select(inputId = "stock_product",
                              label = "Product",
                              choices = get_products()$Name),
                     plotOutput("product_stock_plot")),
               f7Tab(tabName = "Search Store",
                     selectInput(inputId = "searchproducts",
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

