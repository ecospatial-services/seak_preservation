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
# files manually downloaded from ORNL DAAC

# REPROJECT RASTERS ------------------------------------------------------------------
agc.file.in <- 'A:/research/data/biomass/spawn_global/aboveground_biomass_carbon_2010.tif'
agc.uncert.file.in <- 'A:/research/data/biomass/spawn_global/aboveground_biomass_carbon_2010_uncertainty.tif'
bgc.file.in <- 'A:/research/data/biomass/spawn_global/belowground_biomass_carbon_2010.tif'
bgc.uncert.file.in <- 'A:/research/data/biomass/spawn_global/belowground_biomass_carbon_2010_uncertainty.tif'

agc.file.out <- 'A:/research/ecospatial_services/seak_preservation/data/biomass_carbon/aboveground_biomass_carbon_2010_MgChaX10_300m_aeac.tif'
agc.uncert.file.out <- 'A:/research/ecospatial_services/seak_preservation/data/biomass_carbon/aboveground_biomass_carbon_2010_uncertainty_MgChaX10_300m_aeac.tif'
bgc.file.out <- 'A:/research/ecospatial_services/seak_preservation/data/biomass_carbon/belowground_biomass_carbon_2010_MgChaX10_300m_aeac.tif'
bgc.uncert.file.out <- 'A:/research/ecospatial_services/seak_preservation/data/biomass_carbon/belowground_biomass_carbon_2010_uncertainty_MgChaX10_300m_aeac.tif'

gdalwarp(srcfile = agc.file.in, dstfile = agc.file.out, t_srs = as.character(nam.aeac.crs), 
         r = 'bilinear', tr = c(300,300), te = extnt, ot = 'UInt16', dstnodata = 65535, overwrite = T)

gdalwarp(srcfile = agc.uncert.file.in, dstfile = agc.uncert.file.out, t_srs = as.character(nam.aeac.crs), 
         r = 'bilinear', tr = c(300,300), te = extnt, ot = 'UInt16', dstnodata = 65535, overwrite = T)

gdalwarp(srcfile = bgc.file.in, dstfile = bgc.file.out, t_srs = as.character(nam.aeac.crs), 
         r = 'bilinear', tr = c(300,300), te = extnt, ot = 'UInt16', dstnodata = 65535, overwrite = T)

gdalwarp(srcfile = bgc.uncert.file.in, dstfile = bgc.uncert.file.out, t_srs = as.character(nam.aeac.crs), 
         r = 'bilinear', tr = c(300,300), te = extnt, ot = 'UInt16', dstnodata = 65535, overwrite = T)

# TOTAL BIOMASS CARBON ------------------------------------------------------------------------
agc.r <- raster('data/biomass_carbon/aboveground_biomass_carbon_2010_MgChaX10_300m_aeac.tif')
bgc.r <- raster('data/biomass_carbon/belowground_biomass_carbon_2010_MgChaX10_300m_aeac.tif')
c.r <- agc.r + bgc.r
writeRaster(c.r, 'data/biomass_carbon/total_biomass_carbon_2010_MgChaX10_300m_aeac.tif', overwrite = T)

# END SCRIPT ----------------------------------------------------------