# Download PRISM climate norms (1981-2010) for Alaska and the CONUS
# Date: 2021-08-15
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(terra)
require(gdalUtilities)

setwd('A:/research/ecospatial_services/seak_preservation/')
mkdirs('data/climate_connectivity/')
nad83.crs <- CRS('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs')
nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')

# usa.shp <- st_read('A:/research/data/boundaries/USA_adm0.shp')
# usa.aeac.shp <- usa.shp %>% st_transform(nam.aeac.crs)
# extnt <- extent(usa.aeac.shp)
extnt <- c(-4000000,-1700000,2100000,4300000)


# DOWNLOAD AND UNZIP FILES ---------------------------------------------------
url <- 'https://s3-us-west-2.amazonaws.com/www.cacpd.org/Carrolletal2018/centrality.zip'
download.file(url, destfile = 'data/tmp/clim_connect.zip')
unzip('data/tmp/clim_connect.zip', exdir = 'data/tmp/clim_connect', overwrite = T)
unlink('data/tmp/clim_connect.zip')


# REPROJECT RASTERS ------------------------------------------------------------------
file.in <- 'data/tmp/clim_connect/currentflow.tif'
file.out <- 'data/climate_connectivity/current_flow_5000m_aeac.tif'

gdalwarp(srcfile = file.in, dstfile = file.out, t_srs = as.character(nam.aeac.crs), 
         r = 'bilinear', tr = c(5000,5000), te = extnt, ot = 'UInt16', dstnodata = 65535, overwrite = T)

xx <- rast(file.out)
plot(xx)
# END SCRIPT ----------------------------------------------------------