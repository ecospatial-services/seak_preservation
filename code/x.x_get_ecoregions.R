# Download EPA ecoregions for Alaska
# Date: 2021-08-01
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
setwd('A:/research/ecospatial_services/seak_preservation/')
mkdirs('data/tmp')

# download and unzip shapefile
download.file('https://prd-wret.s3-us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/atoms/files/UnifiedEcoregionsAlaska2001.zip', destfile = 'data/tmp/UnifiedEcoregionsAlaska2001.zip')
unzip('data/tmp/UnifiedEcoregionsAlaska2001.zip', exdir = 'data/tmp', overwrite = T)

# read in shapefile
eco.shp <- st_read('data/tmp/akecoregions-ShapeFile/akecoregions.shp')

# set projection
akcea <- CRS('+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs') # Alaska Albers Conical Equal Area
eco.shp <- eco.shp %>% st_set_crs(akcea) 

# select southeast Alaskan ecoregions of interest
seak.eco.shp <- eco.shp %>% filter(COMMONER == 'Boundary Ranges' | COMMONER == 'Alexander Archipelago')

# reproject a copy to WGS84 
seak.eco.wsg84.shp <- seak.eco.shp %>% st_transform(4326)

# write out shapefiles
st_write(seak.eco.wsg84.shp, 'data/seak_ecoregions_wgs84.shp')
st_write(seak.eco.shp, 'data/seak_ecoregions_akcea.shp')

# EPA LEVEL 3 EROREGIONS
# download.file('https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/ak/ak_eco_l3.zip', destfile = 'data/tmp/ak_eco_l3.zip')
# unzip('data/tmp/ak_eco_l3.zip', exdir = 'data/tmp', overwrite = T)
