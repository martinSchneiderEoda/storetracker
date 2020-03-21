

# libraries ---------------------------------------------------------------

library(shiny)
library(shinyMobile)
library(leaflet)
library(DT)
library(DBI)
library(lubridate)
library(geosphere)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
library(geoloc)

# source -------------------------------------------------------------------------

source("../storeFunctions.R")
source("../uiFunctions.R")

con <- dbConnect(RSQLite::SQLite(), "../storeTrackeDB.sqlite")


# -------------------------------------------------------------------------

# replace with db
product_choices <- tbl(con, "Products") %>% pull(ID) 

names(product_choices) <- tbl(con, "Products") %>% pull(Name) 


stores <- tbl(con, "Supermarket") %>% pull(ID)
names(stores) <- tbl(con, "Supermarket") %>% pull(Name) 

store_choices <- tbl(con, "Supermarket") %>% pull(Name)
  

