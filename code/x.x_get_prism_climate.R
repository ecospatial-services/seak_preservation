# Download PRISM climate norms (1981-2010) for Alaska and the CONUS
# Date: 2021-08-15
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
require(gdalUtilities)
setwd('A:/research/ecospatial_services/seak_preservation/')
mkdirs('data/climate/')

# FILES TO DOWNLOAD ----------------------------------------------------------------
# Note: downloaded COUS files manually from https://prism.oregonstate.edu/normals/ on 8/15/2021. Couldn't get URL to use for download
ak.annual.ppt.url <- 'https://prism.oregonstate.edu/projects/public/alaska/grids/ppt/PRISM_ppt_ak_30yr_normal_800mM1_annual_asc.zip'
ak.july.tmax.url <- 'https://prism.oregonstate.edu/projects/public/alaska/grids/tmax/PRISM_tmax_ak_30yr_normal_800mM1_07_asc.zip'

# DOWNLOAD AND UNZIP FILES -------------------------------------------------------------
download.file(ak.annual.ppt.url, destfile = 'data/tmp/prism_ppt_ak_30yr_normal_800m_annual_asc.zip')
download.file(ak.july.tmax.url, destfile = 'data/tmp/prism_tmax_ak_30yr_normal_800m_july_asc.zip')

unzip('data/tmp/prism_ppt_ak_30yr_normal_800m_annual_asc.zip', exdir = 'data/climate', overwrite = T)
unzip('data/tmp/prism_tmax_ak_30yr_normal_800m_july_asc.zip', exdir = 'data/climate', overwrite = T)

unzip('data/tmp/PRISM_ppt_30yr_normal_800mM2_annual_asc.zip', exdir = 'data/climate', overwrite = T)
unzip('data/tmp/PRISM_tmax_30yr_normal_800mM2_07_asc.zip', exdir = 'data/climate', overwrite = T)

# READ IN RASTERS ------------------------------------------------------------------


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

# READ IN SHAPE FILES ------------------------------------------------------
admin.shp <- st_read('data/admin/S_USA.AdministrativeForest.shp')
wilderness.shp <- st_read('data/admin/S_USA.Wilderness.shp')
roadless.shp <- st_read('data/admin/S_USA.RoadlessArea_2001.shp')

# SET PROJECTS AND THEN REPROJECT ----------------------------------------------------------
# https://guides.library.duke.edu/r-geospatial/CRS
nad83.crs <- CRS('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs')
nam.aeac.crs <- CRS('+proj=aea +lat_1=25 +lat_2=65 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')

# EPA LEVEL 3 EROREGIONS
# download.file('https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/ak/ak_eco_l3.zip', destfile = 'data/tmp/ak_eco_l3.zip')
# unzip('data/tmp/ak_eco_l3.zip', exdir = 'data/tmp', overwrite = T)