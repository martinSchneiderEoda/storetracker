#install / load packages

#install.packages("osmdata")
#install.packages("sf")
#install.packages("ggmap")
#install.packages("leaflet")

library(tidyverse)
library(osmdata)
library(sf)
library(ggmap)
library(leaflet)

#connect to osm

#available_features( )

cols_osm <- c("osm_id", "name", "addr.city", "addr.country", "addr.housename", "addr.housenumber", "addr.postcode", "addr.street", 
                 "addr.suburb", "brand", "brand.wikidata", "brand.wikipedia", "building", "building.colour", "building.height", "building.levels", 
                 "building.part", "contact.email", "contact.mobile", "contact.phone", "contact.website", "email", "fax", "height", 
                 "internet_access", "note", "old_name", "opening_hours", "operator", "organic", "payment.cash", "payment.coins", 
                 "payment.contactless", "payment.credit_cards", "payment.debit_cards", "payment.girocard", "payment.mastercard", "payment.notes", "payment.visa", "phone", 
                 "ref", "roof.colour", "roof.levels", "roof.shape", "shop", "source", "source.date", "toilets.wheelchair", 
                 "website", "wheelchair", "geometry")

city <- "kassel"

get_places <- function(city, key = "shop", value = "supermarket") {
  q <- add_osm_feature(opq(getbb(city)),   key = "shop", value = "supermarket")
  osm_places <- osmdata_sf(q)
  sm_points  <- osm_places$osm_points[!is.na(osm_places$osm_points$name), ]
  sm_polygons <- st_centroid(osm_places$osm_polygons[!is.na(osm_places$osm_polygons$name), ])
  
  sm_points[ setdiff(names(sm_points), cols_osm)] <- NULL
  sm_points[ setdiff(cols_osm, names(sm_points))] <- NA
  
  sm_polygons[ setdiff(names(sm_polygons), cols_osm)] <- NULL
  sm_polygons[ setdiff(cols_osm, names(sm_polygons))] <- NA
  
    return(rbind(sm_points, sm_polygons))
  
}




osm_supermarkets <-   get_places("kassel")

#write.table(osm_supermarkets, "C:/temp/workspace/storetracker/supermarkets.csv", sep = "\t", row.names = FALSE, col.names = TRUE)





leaflet() %>% addTiles() %>% 
  addMarkers(data = osm_supermarkets)

