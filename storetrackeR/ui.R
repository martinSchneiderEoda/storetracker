

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
               f7Tab(tabName = "Store Capacity",
                     f7Select(inputId = "capacity_store",
                              label = "Store ID",
                              choices = 1:20),
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
                     f7AutoComplete(inputId = "searchproducts",
                                    label = "Products",
                                    choices = c("Bananen", "Klopapier", "Nudeln"),
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
                       f7AccordionItem(title = "Produkt 1",
                                       f7Select(inputId = "select_product1",
                                                label = "product1",
                                                choices = c("Bananen", "Klopapier", "Nudeln")
                                       ),
                                       f7Select(inputId = "stock_product1",
                                                label = "Stock",
                                                choices = c("leer", "wenig", "normal", "voll")
                                       )
                       ),
                       f7AccordionItem(title = "Produkt 2",
                                       f7Select(inputId = "select_product2",
                                                label = "product2",
                                                choices = c("Bananen", "Klopapier", "Nudeln")
                                       ),
                                       f7Select(inputId = "stock_product2",
                                                label = "Stock",
                                                choices = c("leer", "wenig", "normal", "voll")
                                       )
                       ),
                       f7AccordionItem(title = "Produkt 3",
                                       f7Select(inputId = "select_product3",
                                                label = "product3",
                                                choices = c("Bananen", "Klopapier", "Nudeln")
                                       ),
                                       f7Select(inputId = "stock_product3",
                                                label = "Stock",
                                                choices = c("leer", "wenig", "normal", "voll")
                                       )
                       )
                      ),
                     
                     actionButton(inputId = "add_product",
                                  label = "add Product")
                     
                     )
           )
        )
           
      
)

