#install / load packages

install.packages("osmdata")
install.packages("sf")
install.packages("ggmap")

library(tidyverse)
library(osmdata)
library(sf)
library(ggmap)


#connect to osm

#available_features( )

city <- "kassel"


get_places <- function(city, key = "shop", value = "supermarket") {
  q <- add_osm_feature(opq(getbb(city)),   key = "shop", value = "supermarket")
  osm_places <- osmdata_sf(q)
  return(osm_places)
}


get_places("Kassel")

str(osm_supermarkets)


write.table(osm_supermarkets$osm_polygons, "C:/temp/workspace/storetracker/supermarkets.csv", sep = "\t", row.names = FALSE, col.names = TRUE)

ggmap(mad_map)+
  geom_sf(data = osm_supermarkets$osm_points,
          inherit.aes = FALSE,
          colour = "#238443",
          fill = "#004529",
          alpha = .5,
          size = 4,
          shape = 21)+
  labs(x = "", y = "")
