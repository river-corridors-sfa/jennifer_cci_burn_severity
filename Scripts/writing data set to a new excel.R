# Script for snatching specific columns from the NID database
# packages:
# file reader
install.packages("data.table")
# creates new excel sheet
install.packages("openxlsx")
library("data.table")
library("openxlsx")

# pulling up the dam file and desired columns
dams <- fread("dams.csv", select = c("Dam Name", "Latitude", "Longitude", "River or Stream Name", "City", "State"))
# used the dam object (haha) and wrote the columns onto a new excel
write.xlsx(dams, 'Damlocationsandstreamnames.xlsx')
