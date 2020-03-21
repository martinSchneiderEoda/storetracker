

# libraries ---------------------------------------------------------------

library(shiny)
library(shinyMobile)
library(leaflet)
library(DT)




# source -------------------------------------------------------------------------

source("../storeFunctions.R")
source("../uiFunctions.R")

con <- dbConnect(RSQLite::SQLite(), "../storeTrackeDB.sqlite")


# -------------------------------------------------------------------------

# replace with db
product_choices <- c("Bananen", "Klopapier", "Nudeln")
