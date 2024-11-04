#Title: Making a Dam Map 
#Author: Jennifer Moreno-Ramirez (CCI)
#Description: Reads in excel data table of 1000s of nationally verified dams, 
#returns a document with just the dams, city/state, and coordinates

library("readxl")
library("openxlsx")
library("sf")
library("tidyverse")
library("ggthemes") # theme_map()
library("ggnewscale") # set multiple color scales
library("ggspatial") # add north arrow and scale bar
library("nhdplusTools")
library("data.table")

local_path <- "data/mtbs/wa4685412079920200831/"

# Set common coordinate reference system
# for any spacial things
common_crs = 4326

# make sure you are reading in the file, which makes a data frame
# make sure excel is not open in any tabs, will block the read
# JM damsdb <- read_excel(path = "C:/Users/more173/OneDrive - PNNL/Documents/GitHub/rc_sfa-rc-3-wenas-modeling/data/Damlocationsandstreamnames.xlsx")
damsdb <- read_excel(path = "Damlocationsandstreamnames.xlsx") %>% 
  drop_na()


  # creates points for every dam that can be plotted 
  # na.omit omits dams that don't have lat/long values
  dams_sf <- st_as_sf(damsdb, coords = c("Longitude", "Latitude"), crs = common_crs)
  
  ggplot() + 
    geom_sf(data = dams_sf)
  
  #writes the sf into a .csv file, with coordinates separated into latidude and longitude columns
  st_write(dams_sf, "Damcoords.csv", layer_options = "GEOMETRY=AS_XY")
  
  
  
  #writes the sf into a .csv file with coordinates in a geom point column
  # from https://github.com/r-spatial/sf/issues/284
  #st_write(dams_sf, "Damcoordinates.csv", layer_options = "GEOMETRY=AS_WKT")
  #x <- st_read("Damcoordinates.csv", options = "GEOM_POSSIBLE_NAMES=WKT")
  
  # in this case I'm assuming w10 is an interchangeable sf object that
  # can be changed to any point of interest
  w10 <- tibble(lat = 46.86752, long = -120.7744, site_id = "W10") %>% 
    # creates the point to plot 
    st_as_sf(coords = c("long", "lat"), crs = common_crs)
  
  
  ## Pull Wenas boundary
  wenas_huc10 <- get_huc(AOI = w10, type = "huc10")
  ## Pull flow lines
  
  wenas_flowlines <- get_nhdplus(AOI = wenas_huc10)
  # Check if each dam is within the watershed boundary
  
  ## Check which (if any) dams are interesecting
  intersecting_dams <- st_intersection(dams_sf, wenas_huc10)
  
  ggplot() + 
    geom_sf(data = wenas_huc10) + 
    geom_sf(data = wenas_flowlines) + 
    geom_sf(data = w10) + 
    geom_sf(data = intersecting_dams, color = "red") + 
    theme_bw()
  

  
  

  
  
  dam_on_watershed <- sapply(1:nrow(dams_sf), function(i) {
    point_sf <- dams_sf[i, ]
    st_intersects(point_sf, wenas_huc10, sparse = FALSE)
  })
  # Check if each dam is near a flowline
  dam_on_flowline <- sapply(1:nrow(dams_sf), function(i) {
    point_sf <- dams_sf[i, ]
    st_intersects(point_sf, wenas_flowlines, sparse = FALSE)
  })
  ggplot() + 
    geom_sf(data = dam_on_watershed) + 
    geom_sf(data = dam_on_flowline) +
    geom_sf(data = w10)


