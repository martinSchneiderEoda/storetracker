

# libraries ---------------------------------------------------------------

library(shiny)
library(shinyMobile)
library(leaflet)
library(DT)




# source -------------------------------------------------------------------------

source("../storeFunctions.R")

con <- dbConnect(RSQLite::SQLite(), "../storeTrackeDB.sqlite")