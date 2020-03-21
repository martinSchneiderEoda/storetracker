

f7Page(title = "storetracker",
       geoloc::onload_geoloc(),
       f7TabLayout(
           navbar = f7Navbar(title = "Storetracker"),
           f7Tabs(
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
                     f7DatePicker(inputId = "searchdate",
                                  label = "Date",
                                  value = round_date(Sys.Date())),
                     f7Select("searchhour", "Hour", choices = 9:20),
                     f7Text("searchradio", "Store distance", value = "1"),
                     leafletOutput("storemap", height = 200),
                     dataTableOutput("store_rec_table")
               ),
               f7Tab(tabName = "Track Store",
                   
                     uiOutput("visited_storeU"),
                     
                     f7Slider(inputId = "rate_occupancy",
                              label = "Occupancy",
                              min = 0,
                              max = 100,
                              value = 50),
                     
                    f7Accordion(
                       uiOutput("product_stock")
                      ),
                   
                     f7Button(inputId = "add_product",
                                  label = "add Product"),
                     
                    f7Button(inputId = "submit_stock",
                                 label = "Submit Input")
               )
           )

        )
)

