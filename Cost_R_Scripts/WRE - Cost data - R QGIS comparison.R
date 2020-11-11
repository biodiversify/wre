
####################################### Julia Haywood - Biodiversify - 11-11-2020

####################################### WRE - Cost data - R and QGIS Comparison

####################################### Prepare script

# Clear R memory
rm(list = ls())
.rs.restartR()

# Expand memory
memory.size()                                                                   # Checking memory size
memory.limit()                                                                  # Check set limit
memory.limit(size=56000)                                                        # Expand memory

# Set working directory

# Load in packages
library(sf)
library(rgdal)
library(raster)


####################################### Data preparation

##### QGIS output

# Load in Q Price data

Q_Price <- readOGR(file.choose())                                               # Read in 'Q_Price_by_area.shp'

# Summarise for each group = parish, FT, Quality, and County

Q_price_stats <- aggregate(area_Price ~ objectid + Farm_type + 
                             Quality + County,
                           data=Q_Price, sum, na.action = na.pass)              # Aggregate to each group
Q_area_stats <- aggregate(area_acre ~ objectid + Farm_type + 
                            Quality + County,
                          data=Q_Price, sum, na.action = na.pass)               # Aggregate to each group
Q_stats<- merge(x = Q_price_stats,
                y = Q_area_stats[ , c("objectid", "Farm_type",
                                      "Quality", "area_acre")],
                by = c("objectid", "Farm_type", "Quality"), all.x=TRUE)         # Merge area and price
County<-read.csv (file.choose(),header=TRUE)                                    # Read in 'WRE_Parish_Counties.csv'
Q_stats<- merge(x = Q_stats,
                y = County[ , c("objectid", "parncp19nm")],
                by = 'objectid', all.x=TRUE)                                    # Assign County to each parish
names(Q_stats)[names(Q_stats) == "parncp19nm"] <- "Parish"                      # Rename column
write.csv(Q_stats, 'Q_summary_stats.csv')                                       # Save to .csv

# Summarise for each group = FT + Quality

Q_sum_price <- aggregate(area_Price ~ Farm_type + Quality,
                         data=Q_stats, sum, na.rm=FALSE)                        # Aggregate to each group
Q_sum_area <- aggregate(area_acre ~ Farm_type + Quality,
                        data=Q_stats, sum, na.rm=FALSE)                         # Aggregate to each group

# Summarise for each group = Parish

Q_parish_price <- aggregate(area_Price ~ objectid + Parish + County,
                            data=Q_stats, sum)                                  # Aggregate to each group
Q_parish_area <- aggregate(area_acre ~ objectid + Parish + County,
                           data=Q_stats, sum,na.action = na.pass)               # Aggregate to each group
Q_parish_stats<- merge(x = Q_parish_area,
                       y = Q_parish_price[ , c("objectid", "area_Price")],
                       by = 'objectid', all.x=TRUE)                             # Merge area and price
write.csv(Q_parish_stats, 'Q_Parish_stats.csv')                                 # Save to .csv


##### R outputs

R_Price <- readOGR(file.choose())                                               # Read in 'Price_by_area.shp'


# Summarise for each group = parish, FT, Quality, and county

R_price_stats <- aggregate(area_Price ~ objectid + Farm_type + 
                           Quality + County,
                           data=R_Price, sum, na.action = na.pass)              # Aggregate to each group
R_area_stats <- aggregate(area_acre ~ objectid + Farm_type + 
                           Quality + County,
                           data=R_Price, sum, na.action = na.pass)              # Aggregate to each group
R_stats<- merge(x = R_price_stats,
                y = R_area_stats[ , c("objectid", "Farm_type",
                           "Quality", "area_acre")],
                by = c("objectid", "Farm_type", "Quality"), all.x=TRUE)         # Merge area and price
County<-read.csv (file.choose(),header=TRUE)                                    # Read in 'WRE_Parish_Counties.csv'
R_stats<- merge(x = R_stats,
                y = County[ , c("objectid", "parncp19nm")],
                by = 'objectid', all.x=TRUE)                                    # Assign County to each parish
names(R_stats)[names(R_stats) == "parncp19nm"] <- "Parish"                      # Rename column
write.csv(R_stats, 'R_summary_stats.csv')                                       # Save to .csv

# Summarise for each group = FT + Quality

R_sum_price <- aggregate(area_Price ~ Farm_type + Quality,
                      data=R_stats, sum, na.rm=FALSE)                           # Aggregate to each group
R_sum_area <- aggregate(area_acre ~ Farm_type + Quality,
                         data=R_stats, sum, na.rm=FALSE)                        # Aggregate to each group

# Summarise for each group = Parish

R_parish_price <- aggregate(area_Price ~ objectid + Parish + County,
                          data=R_stats, sum)                                    # Aggregate to each group
R_parish_area <- aggregate(area_acre ~ objectid + Parish + County,
                            data=R_stats, sum,na.action = na.pass)              # Aggregate to each group
R_parish_stats<- merge(x = R_parish_area,
                y = R_parish_price[ , c("objectid", "area_Price")],
                by = 'objectid', all.x=TRUE)                                    # Merge area and price
write.csv(R_parish_stats, 'R_Parish_stats.csv')                                 # Save to .csv


####################################### Analysis


# Once re run with WRE region - join either summary stats and parish stats for R and QGIS - calculate difference in area and price


####################################### END


