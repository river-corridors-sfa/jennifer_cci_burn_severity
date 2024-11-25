
#Title: Making a Dam Map and geom points
#Author: Jennifer Moreno-Ramirez (CCI)
#Description:
# Script for snatching specific columns from the NID database and geom points from long and lat

# packages:
# file reader
install.packages("data.table")
# creates new excel sheet
install.packages("openxlsx")
library("data.table")
library("openxlsx")
library("readxl")
library("sf")
library("tidyverse")
library("nhdplusTools")

# pulling up the dam file and desired columns
dams <- fread("dams.csv", select = c("Dam Name", "Latitude", "Longitude", "River or Stream Name", "City", "State", "NID Height (Ft)", "NID Height Category", "Dam Length (Ft)", "NID Storage (Acre-Ft)"))
# used the dam object (haha) and wrote the columns onto a new excel
write.xlsx(dams, 'Damlocationsandstreamnames.xlsx')

local_path <- "data/mtbs/wa4685412079920200831/"

# Set common coordinate reference system
# for any spacial things
common_crs = 4326

# make sure you are reading in the file, which makes a data frame
# make sure excel is not open in any tabs, will block the read
damsdb <- read_excel(path = "C:/Users/more173/OneDrive - PNNL/Documents/Damlocationsandstreamnamesupdated.xlsx")

# creates points for every dam that can be plotted 
# na.omit omits dams that don't have lat/long values
dams_sf <- st_as_sf(na.omit(damsdb), coords = c("Latitude", "Longitude"), crs = common_crs)

#writes the sf into a .csv file, with coordinates separated into latidude and longitude columns
st_write(dams_sf, "Damcoordsupdated.csv", layer_options = "GEOMETRY=AS_XY")

#writes the sf into a .csv file with coordinates in a geom point column
# from https://github.com/r-spatial/sf/issues/284
st_write(dams_sf, "Damcoordinatesupdated.csv", layer_options = "GEOMETRY=AS_WKT")
x <- st_read("Damcoordinates.csv", options = "GEOM_POSSIBLE_NAMES=WKT")