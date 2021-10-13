# Download PRISM climate norms (1981-2010) for Alaska and the CONUS
# Date: 2021-08-15
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
require(gdalUtilities)
setwd('A:/research/ecospatial_services/seak_preservation/')
mkdirs('data/forest_landscape_integrity/')
nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')
extnt <- c(-4000000,-1700000,2100000,4300000)
# FILES TO DOWNLOAD ----------------------------------------------------------------
flii.url <- 'https://drive.google.com/file/d/1EHt_2Zah5-wCV7JRDafw297HeX80Kh6_/view?usp=sharing'

# DOWNLOAD AND UNZIP FILES -------------------------------------------------------------
# downloaded from: https://drive.google.com/drive/folders/180DXlbF4dwCYhBW025YkZbhNHnrW5NlW

# REPROJECT RASTER ------------------------------------------------------------------
flii.file.in <- 'A:/research/data/human_impact/forest_landscape_integrity/flii_NorthAmerica.tif'
flii.file.out <- 'A:/research/ecospatial_services/seak_preservation/data/forest_landscape_integrity/flii_nam_300m_aeac.tif'

gdalwarp(srcfile = flii.file.in, dstfile = flii.file.out, t_srs = as.character(nam.aeac.crs), 
         srcnodata = -9999, dstnodata = 65535, r = 'bilinear', tr = c(300,300), te = extnt, 
         ot = 'UInt16', overwrite = T)

# END SCRIPT ----------------------------------------------------------