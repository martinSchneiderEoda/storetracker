#install / load packages

install.packages("osmdata")
install.packages("sf")
install.packages("ggmap")
install.packages("leaflet")

library(tidyverse)
library(osmdata)
library(sf)
library(ggmap)
library(leaflet)

#connect to osm

#available_features( )

city <- "kassel"


get_places <- function(city, key = "shop", value = "supermarket") {
  q <- add_osm_feature(opq(getbb(city)),   key = "shop", value = "supermarket")
  osm_places <- osmdata_sf(q)
  return(osm_places)
}

osm_supermarkets <-   get_places("kassel")

#write.table(osm_supermarkets$osm_polygons, "C:/temp/workspace/storetracker/supermarkets.csv", sep = "\t", row.names = FALSE, col.names = TRUE)


#leaflet erstellen

supermarkets_points <- osm_supermarkets$osm_points[!is.na(osm_supermarkets$osm_points$name), ]
supermarkets_polygons <- osm_supermarkets$osm_polygons[!is.na(osm_supermarkets$osm_polygons$name), ]

leaflet() %>% addTiles() %>% 
  addPolygons(data = supermarkets_polygons)# %>% 
  addMarkers(data = points)


