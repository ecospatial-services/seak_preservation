# Date: 2023-1-12
# https://www.envidat.ch/#/metadata/bioclim_plus
rm(list=ls())
require(R.utils)
require(terra)
require(gdalUtilities)
require(gdalUtils)
require(data.table)
setwd('A:/research/ecospatial/seak_preservation/')
mkdirs('data/climate/')
mkdirs('data/climate/0_orig_files/')
wgs84.crs <- crs("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
nam.aeac.crs <- crs('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')
extnt <- c(-4000000,-1700000,2100000,4300000)

# Data citation:
# Philipp Brun; Niklaus E. Zimmermann; Chantal Hari; Loïc Pellissier; Dirk Nikolaus Karger (2022). 
# CHELSA-BIOCLIM+ A novel set of global climate-related predictors at kilometre-resolution. 
# EnviDat. doi: 10.16904/envidat.332.


# REPROJECT RASTER ------------------------------------------------------------------
mkdirs('data/climate/2_proj/')

in.files <- list.files('data/climate/0_orig/', full.names = T)
out.files <- paste0('data/climate/2_proj/', list.files('data/climate/0_orig/'))

for (i in 1:length(in.files)){
  gdalwarp(srcfile = in.files[i],
           dstfile = out.files[i],
           t_srs = as.character(nam.aeac.crs), 
           r = 'average', tr = c(300,300), te = extnt, 
           ot = 'Int32', overwrite = T)
  print(paste0('done: ', in.files[i]))
}

# check output
rr <- rast('data/climate/2_proj/CHELSA_bio12_1981-2010_V.2.1.tif')
rr  
plot(rr)

# END SCRIPT ----------------------------------------------------------