
####################################### Julia Haywood - Biodiversify - 11-11-2020

####################################### WRE - Cost data - R

####################################### Preliminary work

##### Cost data sources

# WRE Region - Provided by Siso - *REPLACE WHEN WRE PROVIDE TRUE EXTENT*
# Parishes = https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(BDY_PARNCP%2CDEC_2019)
# Parishes - Create a .csv of parishes and their County. Note - Parishes of the same name occur in different counties
# FP - Average farmland price = https://www.fwi.co.uk/business/markets-and-trends/land-markets/find-out-average-farmland-prices-where-you-live
# FP - Create a .csv of price per land type, quality and county. Note - some counties missing (NA)
# ALC - Provisional Agricultural Land Classification Grade = https://naturalengland-defra.opendata.arcgis.com/datasets/provisional-agricultural-land-classification-alc-england/data
# LC - Land cover map 2019 = https://catalogue.ceh.ac.uk/documents/44c23778-4a73-4a8f-875f-89b23b91ecf8


##### QGIS

# Parish:
# Buffer UK_Parishes with distance = 0 to remove invalid geometries. Check with 'Check validity'
# Output: 'UK_Buffered_Parishes.shp'

# ALC:
# Buffer ALC with distance = 0 to remove invalid geometries. Check with 'Check validity'
# Output: 'UK_Buffered_ALC.shp'

# LC:
# Polygonize 'WRE_LC_Classifications.tif' to 'WRE_LC_Classifications.shp' ~ 1 day
# Buffer WRE_LC_FT with distance = 0 to remove invalid geometries. Check with 'Check validity'
# Output: 'Buffer_WRE_LC_FT.shp'


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


####################################### Analysis

####################################### Data preparation

# Load in WRE Region

WRE <- readOGR(file.choose())                                                   # Read in 'WRE_Region.shp'
WRE@data                                                                        # Check/visualise data
st_crs(WRE)                                                                     # Check projection - OSGB EPSG 27700
plot(WRE)                                                                       # Plot

# Load in UK Parish data

# Buffer UK_Parishes with distance = 0 to remove invalid geometries.Check with 'Check validity'. Save as 'UK_Buffered_Parishes.shp'

UK_Parish <- readOGR(file.choose())                                             # Read in 'UK_Buffered_Parishes.shp'
UK_Parish@data                                                                  # Check/visualise data
st_crs(UK_Parish)                                                               # Check projection - OSGB EPSG 27700
plot(UK_Parish)                                                                 # Plot
plot(WRE, add=TRUE, col='red')                                                  

# Prepare WRE Parish data

st_crs(UK_Parish)==st_crs(WRE)                                                  # Check same projections
WRE_Parishes<-crop(UK_Parish, WRE)                                              # Crop Parish to WRE region
WRE_Parishes@data                                                               # Check/visualise data
plot(WRE_Parishes)                                                              # Plot

# Assign County to each Parish

County<-read.csv (file.choose(),header=TRUE)                                    # Read in 'WRE_Parish_Counties.csv'
WRE_Parishes<- merge(x = WRE_Parishes,
                     y = County[ , c("objectid", "County")],
                     by = 'objectid', all.x=TRUE)                               # Assign County to each parish
writeOGR(WRE_Parishes, dsn='WRE_Parishes',
        layer='WRE_Parishes', driver="ESRI Shapefile")                          # Save as WRE_Parishes.shp

# Load in UK ALC data

# Buffer ALC with distance = 0 to remove invalid geometries. Check with 'Check validity'. Save as 'UK_Buffered_ALC.shp'

UK_ALC <- readOGR(file.choose())                                                # Read in 'UK_Buffered_ALC.shp'
UK_ALC@data                                                                     # Check/visualise data
st_crs(UK_ALC)                                                                  # Check projection - OSGB EPSG 27700
plot(UK_ALC)                                                                    # Plot
plot(WRE, add=TRUE, col='red')

# Prepare WRE ALC data

st_crs(UK_ALC)==st_crs(WRE)                                                     # Check same projections
WRE_ALC<-crop(UK_ALC, WRE)                                                      # Crop ALC to WRE region
WRE_ALC@data                                                                    # Check/visualise data
plot(WRE_ALC)                                                                   # Plot
WRE_ALC$Quality <- ifelse(endsWith(WRE_ALC$ALC_GRADE, "1") |
                      endsWith(WRE_ALC$ALC_GRADE, "2"), "Prime",
               ifelse(endsWith(WRE_ALC$ALC_GRADE, "3"), "Average",
               ifelse(endsWith(WRE_ALC$ALC_GRADE, "4") |
                      endsWith(WRE_ALC$ALC_GRADE, "5"), "Poor", 
               ifelse(endsWith(WRE_ALC$ALC_GRADE, "al"), "Non Agricultural",
               "Urban"))))                                                      # Add a 'Quality' attribute based in ALC_Grade
writeOGR(WRE_ALC, dsn='WRE_ALC', layer='WRE_ALC', driver="ESRI Shapefile")      # Save as WRE_ALC.shp

# Load in LC raster data

LC <- raster (file.choose())                                                    # Read in 'gb2019lcm20m.tif'
LC                                                                              # View data 
crs(LC)                                                                         # Check projection
crs(LC) <- CRS("+init=epsg:27700")                                              # Set projection - OSGB EPSG 27700
plot(LC)                                                                        # Plot

# Prepare LC raster data

band1<-LC[[1]]                                                                  # Extract band 1 = the 21 UKCEH Land Cover Classes
writeRaster(band1,'UK_LC.tif')                                                  # Save LC for all of UK
WRE_band1 <- crop(band1, WRE)                                                   # Crop to WRE extent
WRE_band1 <- mask(WRE_band1, WRE)                                               # Crop to WRE polygon
plot(WRE_band1)                                                                 # Plot 
plot(WRE, add = TRUE)
writeRaster(WRE_band1,'WRE_LC.tif')                                             # Save as WRE_LC.tiff

# QGIS - Polygonize raster to vector in QGIS, save as 'WRE_LC.shp'

WRE_LC <- readOGR(file.choose())                                                # Read in 'WRE_LC.shp'
WRE_LC@data                                                                     # Check/visualise data
st_crs(WRE_LC)                                                                  # Check projection - OSGB EPSG 27700
plot(WRE_LC)                                                                    # Plot
WRE_LC$Farm_type <- ifelse(endsWith(WRE_LC$Habitat, "3"),"Arable",
                    ifelse(endsWith(WRE_LC$Habitat, "4") |
                           endsWith(WRE_LC$Habitat, "5"), "Pasture",
                    ifelse(endsWith(WRE_LC$Habitat, "20") |
                           endsWith(WRE_LC$Habitat, "21"), "Urban",
                    "Other")))                                                  # Add 'Farm_type' attribute based in LC classification
writeOGR(WRE_LC, dsn='WRE_LC', layer='WRE_LC_FT', driver="ESRI Shapefile")      # Save as WRE_LC_FT.shp

# QGIS - Open 'WRE_LC_FT' in QGIS, buffer with distance = 0, and save as 'Buffer_WRE_LC_FT.shp'


####################################### Data extraction

# Load in data

WRE_Parishes <- st_read('WRE_Parishes.shp')                                     # Read in 'WRE_Parish.shp'
WRE_ALC <- st_read('WRE_ALC.shp')                                               # Read in 'WRE_ALC.shp'
WRE_LC <- st_read('Buffer_WRE_LC_FT.shp')                                       # Read in 'Buffer_WRE_LC_FT.shp'

# Extract data from ALC and LC to each parish

Price <- st_intersection(WRE_Parishes, WRE_ALC)                                 # Extract ALC - took 1 min
Price <- st_intersection(Price, WRE_LC)                                         # Extract LC - took ~ 4 hours
Price <- st_collection_extract(Price, "POLYGON")                                # Convert GEOMETRY to POLYGON 

# Extract price

FP <- read.csv (file.choose(),header=TRUE)                                      # Read in 'Farmland_price_FW.csv'
Price <- merge(Price, FP, by.x = c("County", 'Farm_type',"Quality"),
             by.y = c("County",'Farm_type', "Quality"),
             all.x = TRUE, all.y = TRUE)                                        # Assign price
st_write(Price, "Price.shp", driver="ESRI Shapefile")                           # Save as Price.shp 


# Price per area

Price <- readOGR(file.choose())                                                 # Read in 'Price.shp'
Price$area_sqkm <- area(Price) / 1000000                                        # Calculate the area of each polygon 
Price$area_acre <- (Price$area_sqkm * 247.10538146717)
Price$area_Price <- (Price$area_acre * Price$Price)                             # Calculate price of each polygon
writeOGR(Price, dsn='Price', layer='Price_by_area', driver="ESRI Shapefile")    # Save to .shp


####################################### END


