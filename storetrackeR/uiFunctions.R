

create_stock_rater <- function(id) {
  
  #f7AccordionItem(title = "Bitte teile uns den aktuellen Vorrat mit",
  tagList(                
  f7AutoComplete(inputId = paste0("select_product", id),
                           label = paste("Product", id),
                           value = NULL,
                           choices = names(product_choices)
                  ),
  f7Slider(inputId = paste0("stock_product", id),
           label = "Stock",
           min = 0,
           max = 100,
           value = 50
           )
  )
 # )
}