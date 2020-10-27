##great job julia :)
################################ WRE - Cost data

##### Cost data sources:

# WRE Region shapefile - Provided by Siso - REPLACE WHEN WRE PROVIDE TRUE EXTENT
# County shapefile = created from ONS 'Counties' and 'Counties and Unitary Authorities' boundaries
# FP - Average farmland price = https://www.fwi.co.uk/business/markets-and-trends/land-markets/find-out-average-farmland-prices-where-you-live
# ALC - Provisional Agricultural Land Classification Grade = https://naturalengland-defra.opendata.arcgis.com/datasets/provisional-agricultural-land-classification-alc-england/data
# LC - Land cover map 2019 = https://catalogue.ceh.ac.uk/documents/44c23778-4a73-4a8f-875f-89b23b91ecf8


####################################### Analysis

##### Data preparation

# Set working directory

# Load in WRE Region

library(sf)
library(rgdal)
WRE <- readOGR(file.choose())                                                   # Read in 'WRE_Region.shp'
WRE@data                                                                        # Check/visualise data
st_crs(WRE)                                                                     # Check projection - OSGB EPSG 27700
plot(WRE)                                                                       # Plot

# Load in County data

County <- readOGR(file.choose())                                                # Read in 'WRE_Counties.shp'
County@data                                                                     # Check/visualise data
st_crs(County)                                                                  # Check projection - OSGB EPSG 27700
plot(County)

# Load in Parish data

Parish <- readOGR(file.choose())                                                # Read in 'WRE_Parish.shp'
Parish@data                                                                     # Check/visualise data
st_crs(Parish)                                                                  # Check projection - OSGB EPSG 27700
plot(Parish)

# Load in Farm price data

FP<-read.csv (file.choose(),header=TRUE)                                        # Read in 'Farmland_price_FW.csv'

# Load in ALC data

ALC <- readOGR(file.choose())                                                   # Read in 'ALC_Grades__Provisional____ADAS___Defra.shp'
ALC@data                                                                        # Check/visualise data
st_crs(ALC)                                                                     # Check projection - OSGB EPSG 27700
plot(ALC)                                                                       # Plot

# Prepare ALC data

ALC$Quality <- ifelse(endsWith(ALC$ALC_GRADE, "1") |
                      endsWith(ALC$ALC_GRADE, "2"), "Prime",
               ifelse(endsWith(ALC$ALC_GRADE, "3"), "Average",
               ifelse(endsWith(ALC$ALC_GRADE, "4") |
                      endsWith(ALC$ALC_GRADE, "5"), "Poor", 
               ifelse(endsWith(ALC$ALC_GRADE, "al"), "Non Agricultural", "Urban"))))         # Add a 'Quality' attribute based in ALC_Grade

# Load in LC raster data

library(raster)
LC <- raster (file.choose())                                                    # Read in 'gb2019lcm20m.tif'
LC                                                                              # View data 
crs(LC)                                                                         # Check projection
crs(LC) <- CRS("+init=epsg:27700")                                              # Set projection - OSGB EPSG 27700
plot(LC)                                                                        # Plot

# Prepare LC raster data

band1<-LC[[1]]                                                                  # Extract band 1 - this band is the 21 UKCEH Land Cover Classes
# writeRaster(band1,'UK_LC_Classifications.tif')                                # Save LC for all of UK
WRE_band1 <- crop(band1, WRE)                                                   # Crop to WRE extent
WRE_band1 <- mask(WRE_band1, WRE)                                               # Crop to WRE polygon
plot(WRE_band1)                                                                 # Plot 
plot(WRE, add = TRUE)
# writeRaster(WRE_band1,'WRE_LC_Classifications.tif')                           # Save LC for WRE region
WRE_band1 <- raster (file.choose())                                             # Read in 'WRE_LC_Classifications.tif'

# Polygonize raster to vector in QGIS

# Load in WRE LC vector data

WRE_LC <- readOGR(file.choose())                                                # Read in 'WRE_LC_Classifications.shp'
WRE_LC@data                                                                     # Check/visualise data
st_crs(WRE_LC)                                                                  # Check projection - OSGB EPSG 27700
plot(WRE_LC)                                                                    # Plot

# Prepare WRE LC vector data

WRE_LC$Farm_type <- ifelse(endsWith(WRE_LC$Band1, "3"),"Arable",
                    ifelse(endsWith(WRE_LC$Band1, "4") |
                           endsWith(WRE_LC$Band1, "5"), "Pasture", "Other"))    # Add a 'Farm_type' attribute based in LC classification


##### Data extraction








# create a blank shapefile or load in England or parishes in WRE
# split in to ALC and LC polygons
# extract the ALC, LC and county in to each polygon
# match the data from new shp to the FP data - use sum of price in each parish

