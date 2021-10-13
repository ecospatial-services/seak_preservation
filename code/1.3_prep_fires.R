# Download PRISM climate norms (1981-2010) for Alaska and the CONUS
# Date: 2021-08-15
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
require(gdalUtilities)
setwd('A:/research/ecospatial_services/seak_preservation/')
mkdirs('data/biomass_carbon/')
nad83.crs <- CRS('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs')
nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')

# usa.shp <- st_read('A:/research/data/boundaries/USA_adm0.shp')
# usa.aeac.shp <- usa.shp %>% st_transform(nam.aeac.crs)
# extnt <- extent(usa.aeac.shp)
extnt <- c(-4000000,-1700000,2100000,4300000)

# DOWNLOAD FILES -------------------------------------------------------------
# files downloaded from GEE

# REPROJECT RASTERS ------------------------------------------------------------------
fire.file.in <- 'A:/research/ecospatial_services/seak_preservation/data/disturbance/modis_v6_usa_burned_area_2001to2020_500m.tif'
fire.file.out <- 'A:/research/ecospatial_services/seak_preservation/data/disturbance/modis_v6_usa_burned_area_2001to2020_300m_laea.tif'

gdalwarp(srcfile = fire.file.in, dstfile = fire.file.out, t_srs = as.character(nam.aeac.crs), 
         r = 'nearest', tr = c(300,300), te = extnt, overwrite = T, ot = 'Byte')

# END SCRIPT ----------------------------------------------------------