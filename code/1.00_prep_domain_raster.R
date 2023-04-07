# Create a domain raster with unique cell ID's 
# Date: 2023-01-15
rm(list=ls())
require(terra)
setwd('A:/research/ecospatial/seak_preservation/')
mkdirs('data/domain/')
nam.aeac.crs <- crs('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')
extnt <- c(-4000000,-1700000,2100000,4300000)

domain.r <- rast(xmin=extnt[1], 
                 xmax=extnt[3], 
                 ymin=extnt[2],
                 ymax=extnt[4], 
                 crs = nam.aeac.crs, 
                 resolution = 300)

domain.r[] <- 1:ncell(domain.r)

writeRaster(domain.r, 'data/domain/analysis_domain_aeac_300m.tif', overwrite=T)
