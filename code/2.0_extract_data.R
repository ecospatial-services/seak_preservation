# Analyze vegetation crabon stocks for NFs
# Date: 2021-09-19
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
require(gdalUtilities)
require(data.table)
require(ggplot2)
setwd('A:/research/ecospatial_services/seak_preservation/')

# LOAD FILES AND SIMPLE PREP ======================================================================
nf.shp <- st_read('data/admin/national_forests_aeac.shp')
flii.r <- raster('data/forest_landscape_integrity/flii_nam_300m_aeac.tif')
totc.r <- raster('data/biomass_carbon/total_biomass_carbon_2010_MgChaX10_300m_aeac.tif')
fire.r <- raster('data/disturbance/modis_v6_usa_burned_area_2001to2020_300m_laea.tif')

# when extracting data, each NFs is given a number basde on it's row in nf.shp, so here simply
# give each NF an ID that corresponds with it's rows...
nf.shp$ID <- 1:length(nf.shp$NFSLANDU_2) 

# EXTRACT FOREST LAND SCAPE INTEGRITY VALUES FOR EACH NF ======================================
nf.dt <- data.table(extract(flii.r, nf.shp, df = T))
nf.dt$nf.name <- nf.shp$NFSLANDU_2[match(nf.dt$ID, nf.shp$ID)] # append forest name to each grid cell
setnames(nf.dt, 'flii_nam_300m_aeac', 'flii') 
nf.dt[, flii := flii/1000] # scale so 0 - 10 as per Grantham et al. 2020
setcolorder(nf.dt, neworder = c('nf.name','ID','flii'))


# EXTRACT VEGETATION CARBON VALUES FOR EACH NF ================================================
totc.dt <- data.table(extract(totc.r, nf.shp, df = T))
setnames(totc.dt, 'total_biomass_carbon_2010_MgChaX10_300m_aeac', 'totc.MgCha')
totc.dt[, totc.MgCha := totc.MgCha/10] # scale to Mg C / ha
totc.dt[, totc.MgCpxl := totc.MgCha * 9] # compute total C per grid cell (there are 9 ha per 300 x 300 m grid cell)

nf.dt$totc.MgCha <- totc.dt$totc.MgCha
nf.dt$totc.MgCpxl <- totc.dt$totc.MgCpxl
rm(totc.dt)


# EXTRACT FIRE DISTURBANCE VALUES FOR EACH NF ================================================
fire.dt <- data.table(extract(fire.r, nf.shp, df = T))
setnames(fire.dt, 'modis_v6_usa_burned_area_2001to2020_300m_laea', 'burned')
nf.dt$burned <- fire.dt$burned

# WRITE OUTPUT FILES ========================================================================== 
fwrite(nf.dt, 'output/natl_forest_data_extraction.csv')
# nf.dt <- fread('output/natl_forest_data_extraction.csv')

# END SCRIPT =================================================================================