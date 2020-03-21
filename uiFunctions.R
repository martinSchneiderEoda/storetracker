

create_stock_rater <- function(id) {
  
  f7AccordionItem(title = paste("Produkt", id),
                  f7Select(inputId = paste0("select_product", id),
                           label = paste("Product", id),
                           choices = product_choices
                  ),
                  f7Slider(inputId = paste0("stock_product", id),
                           label = "Stock",
                           min = 0,
                           max = 100,
                           value = 50
                    
                  )
  )
}