
####################################### Julia Haywood - Biodiversify - 11-11-2020

####################################### WRE - Cost data - QGIS 

####################################### Preliminary work

# In QGIS create the 'Cost.shp' (includes Parish, County, Farm_Type, and Quality for WRE region).
# Follow WRE_Cost_QGIS_Methods.doc

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

####################################### Data extraction

##### Extract Price

# Load in data
Q_Price <- readOGR(file.choose())                                               # Read in 'Cost.shp' -  - As created using 'WRE - Cost data - Methods.doc'
FP <- read.csv (file.choose(),header=TRUE)                                      # Read in 'Farmland_price_FW.csv'

# Extract Price

Q_Price <- merge(Q_Price, FP, by.x = c("County", 'Farm_type',"Quality"),
              by.y = c("County",'Farm_type', "Quality"),
              all.x = TRUE, all.y = TRUE)                                       # Assign price
writeOGR(Q_Price, dsn='Q_Price', layer='Q_Price', driver="ESRI Shapefile")      # Save to .shp


# Price per area

Q_Price$area_sqkm <- area(Q_Price) / 1000000                                    # Calculate the area of each polygon 
Q_Price$area_acre <- (Q_Price$area_sqkm * 247.10538146717)
Q_Price$area_Price <- (Q_Price$area_acre * Q_Price$Price)                       # Calculate price of each polygon
writeOGR(Q_Price, dsn='Q_Price', layer='Q_Price_by_area',
         driver="ESRI Shapefile")                                               # Save to .shp


####################################### END


