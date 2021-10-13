# Download and project USFS administrative boundaries of various kinds (National Forests, Wilderness Areas, ...)
# Date: 2021-08-15
# Author: Logan Berner, EcoSpatial Services LLC
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
setwd('A:/research/ecospatial_services/seak_preservation/')
mkdirs('data/admin/')

# FILES TO DOWNLOAD ----------------------------------------------------------
usfs.land.units.url <- 'https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.NFSLandUnit.zip'
wilderness.url <- 'https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.Wilderness.zip'
roadless.url <- 'https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.RoadlessArea_2001.zip'
roads.url <- 'https://data.fs.usda.gov/geodata/edw/edw_resources/shp/S_USA.RoadCore_FS.zip'

# DOWNLOAD AND UNZIP FILES ---------------------------------------------------
download.file(usfs.land.units.url, destfile = 'data/tmp/usfs_landunits.zip')
unzip('data/tmp/usfs_landunits.zip', exdir = 'data/admin', overwrite = T)
unlink('data/tmp/usfs_landunits.zip')

download.file(wilderness.url, destfile = 'data/tmp/USA.Wilderness.zip')
unzip('data/tmp/USA.Wilderness.zip', exdir = 'data/admin', overwrite = T)
unlink('data/tmp/USA.Wilderness.zip')

download.file(roadless.url, destfile = 'data/tmp/USA.RoadlessArea_2001.zip')
unzip('data/tmp/USA.RoadlessArea_2001.zip', exdir = 'data/admin', overwrite = T)
unlink('data/tmp/USA.RoadlessArea_2001.zip')

download.file(roadless.url, destfile = 'data/tmp/S_USA.RoadCore_FS.zip')
unzip('data/tmp/S_USA.RoadCore_FS.zip', exdir = 'data/admin', overwrite = T)
unlink('data/tmp/S_USA.RoadCore_FS.zip')

# READ IN SHAPE FILES ------------------------------------------------------
nf.shp <- st_read('data/admin/S_USA.NFSLandUnit.shp')
wilderness.shp <- st_read('data/admin/S_USA.Wilderness.shp')
roadless.shp <- st_read('data/admin/S_USA.RoadlessArea_2001.shp')

# SET PROJECTS AND THEN REPROJECT ----------------------------------------------------------
# https://guides.library.duke.edu/r-geospatial/CRS
nad83.crs <- CRS('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs')
nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')

nf.shp <- nf.shp %>% st_set_crs(nad83.crs) 
nf.aeac.shp <- nf.shp %>% st_transform(nam.aeac.crs)
nf.aeac.shp <- nf.aeac.shp %>% filter(NFSLANDU_1 == 'National Forest')
st_write(nf.aeac.shp, dsn = 'data/admin/national_forests_aeac.shp', append = F)

wilderness.shp <- wilderness.shp %>% st_set_crs(nad83.crs) 
wilderness.aeac.shp <- wilderness.shp %>% st_transform(nam.aeac.crs)
st_write(wilderness.aeac.shp, dsn = 'data/admin/wilderness_aeac.shp', append = F)

roadless.shp <- roadless.shp %>% st_set_crs(nad83.crs) 
roadless.aeac.shp <- roadless.shp %>% st_transform(nam.aeac.crs)
st_write(roadless.aeac.shp, dsn = 'data/admin/roadless_aeac.shp', append = F)

# END SCRIPT ---------------------------------------------------------------