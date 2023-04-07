# Download and process soil organic carbon stock dataset from Open Land Map
# Date: 2022-01-02
rm(list=ls())
require(R.utils)
require(sf)
require(terra)
require(gdalUtilities)
setwd('A:/research/ecospatial/seak_preservation/')
mkdirs('data/soil_carbon/')
mkdirs('data/tmp/soil_carbon/')

nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')
extnt <- c(-4000000,-1700000,2100000,4300000)

# DOWNLOAD FILES -------------------------------------------------------------
mkdirs('data/tmp/soil_carbon/0_orig')
# Initally downloaded these files programatically using the code below.
# However, all the spatial metadata (e.g., extent, resolution, CRS) were getting lost.
# Not sure why. Files are fine when downloaded by hand... so did it manually.

# https://zenodo.org/record/2536040#.YdIhyWjMKUk
get.files <- c('https://zenodo.org/record/2525666/files/sol_organic.carbon.stock_msa.kgm2_m_250m_b0..10cm_1950..2017_v0.2.tif?download=1',
              'https://zenodo.org/record/2525666/files/sol_organic.carbon.stock_msa.kgm2_m_250m_b10..30cm_1950..2017_v0.2.tif?download=1',
              'https://zenodo.org/record/2525666/files/sol_organic.carbon.stock_msa.kgm2_m_250m_b30..60cm_1950..2017_v0.2.tif?download=1',
              'https://zenodo.org/record/2525666/files/sol_organic.carbon.stock_msa.kgm2_m_250m_b60..100cm_1950..2017_v0.2.tif?download=1',
              'https://zenodo.org/record/2525666/files/sol_organic.carbon.stock_msa.kgm2_m_250m_b100..200cm_1950..2017_v0.2.tif?download=1')

get.files.names <- paste0('olm_soil_carbon_', c('0..10cm','10..30cm','30..60cm','60..100cm','100..200cm'),'.tif')

for (i in 1:length(get.files)){
  downloadFile(get.files[i], destfile = paste0('data/tmp/soil_carbon/', get.files.names[i]))
}

# CHECKOUT RASTER --------------------------------------------------------------------
rr <- rast('data/tmp/soil_carbon/sol_organic.carbon.stock_msa.kgm2_m_250m_b0..10cm_1950..2017_v0.2.tif')
rr
plot(rr)

# REPROJECT, CLIP, AND RESAMPLE RASTERS ------------------------------------------------------------------
mkdirs('data/tmp/soil_carbon/1_clip_proj')
files.in <- list.files('data/tmp/soil_carbon/0_orig/', full.names = T)
files.out <- paste0('data/tmp/soil_carbon/1_clip_proj/', basename(list.files('data/tmp/soil_carbon/0_orig/', full.names = T)))

for (i in 1:length(files.in)){
  gdalwarp(srcfile = files.in[i], dstfile = files.out[i], t_srs = as.character(nam.aeac.crs), 
         r = 'bilinear', tr = c(300,300), te = extnt, ot = 'UInt16', dstnodata = 65535, overwrite = T)
}

# check output
rr <- rast('data/tmp/soil_carbon/1_clip_proj/sol_organic.carbon.stock_msa.kgm2_m_250m_b0..10cm_1950..2017_v0.2.tif')
rr
plot(rr)


# CALCULATE TOTAL SOIL CARBON STOCKS (0-200 cm) in MgC / ha ----------------------------------------------------
# Note: Original units in Kg C / m2, so multiply by 10 to get into Mg C / ha
soc.stk <- rast(list.files('data/tmp/soil_carbon/1_clip_proj/', full.names = T))
soc.sum.r <- tapp(soc.stk, index = rep(1,5), fun=sum)
soc.MgCha.r <- soc.sum.r*10

writeRaster(soc.MgCha.r, 
            filename = 'data/soil_carbon/openlandmap_soil_carbon_stock_0to200cm_MgCha_300m_aeac.tif', 
            datatype="INT2U", overwrite=T)


soc.stk <- rast(list.files('data/tmp/soil_carbon/1_clip_proj/', full.names = T)[c(1,2,4,5)])
soc.sum.r <- tapp(soc.stk, index = rep(1,4), fun=sum)
soc.MgCha.r <- soc.sum.r*10

writeRaster(soc.MgCha.r, 
            filename = 'data/soil_carbon/openlandmap_soil_carbon_stock_0to100cm_MgCha_300m_aeac.tif', 
            datatype="INT2U", overwrite=T)

# END SCRIPT ----------------------------------------------------------

xx <- rast('data/soil_carbon/openlandmap_soil_carbon_stock_0to100cm_MgCha_300m_aeac.tif')
yy <- rast('data/soil_carbon/openlandmap_soil_carbon_stock_0to200cm_MgCha_300m_aeac.tif')

zz <- xx/yy
plot(zz)
