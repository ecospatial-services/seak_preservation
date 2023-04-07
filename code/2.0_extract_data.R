# Analyze vegetation crabon stocks for NFs
# Date: 2022-11-06
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(terra)
require(exactextractr)
require(gdalUtilities)
require(data.table)
require(ggplot2)

# LOAD FILES AND SIMPLE PREP ======================================================================
nf.shp <- st_read('data/admin/national_forests_aeac.shp')
nf.vec <- vect('data/admin/national_forests_aeac.shp')
id.r <- rast('data/domain/analysis_domain_aeac_300m.tif')
treecov.r <- rast('data/tree_cover/glad_treecover_2010_north_america_300m_aeac.tif')
agc.r <- rast('data/biomass_carbon/aboveground_biomass_carbon_2010_MgChaX10_300m_aeac.tif')
bgc.r <- rast('data/biomass_carbon/belowground_biomass_carbon_2010_MgChaX10_300m_aeac.tif')
boc.r <- rast('data/biomass_carbon/total_biomass_carbon_2010_MgChaX10_300m_aeac.tif')
soc.r <- rast('data/soil_carbon/openlandmap_soil_carbon_stock_0to100cm_MgCha_300m_aeac.tif')
flii.r <- rast('data/forest_landscape_integrity/flii_nam_300m_aeac.tif')
fire.r <- rast('data/disturbance/modis_v6_usa_burned_area_2001to2020_300m_laea.tif')
flow.r <- rast('data/climate_connectivity/current_flow_5000m_aeac.tif')
gap.sts.r <- rast('data/gap_pad/padus_gap_status_nam_300m_aeac.tif')
fed.r <- rast('data/gap_pad/padus_management_fed_nam_300m_aeac.tif')
habitat.files <- list.files('data/gap_habitat/9_final/', full.names = T, pattern = glob2rx('*.tif'))
clim.files <- list.files('data/climate/2_proj/', full.names = T, pattern = glob2rx('*.tif'))  

# when extracting data, each NFs is given a number basde on it's row in nf.shp, so here simply
# give each NF an ID that corresponds with it's rows...
nf.shp$ID <- 1:length(nf.shp$NFSLANDU_2) 

# EXTRACT CELL ID WITHIN EACH NF ======================================
nf.dt <- data.table(extract(id.r, nf.vec, df = T))
nf.dt$nf.name <- nf.shp$NFSLANDU_2[match(nf.dt$ID, nf.shp$ID)] # append forest name to each grid cell
setnames(nf.dt, 'lyr.1', 'cell.id') 
setcolorder(nf.dt, neworder = c('nf.name','ID','cell.id'))


# EXTRACT TREE COVER FOR EACH NF ======================================
treecov.dt <- data.table(extract(treecov.r, nf.vec, df = T))
treecov.dt$nf.name <- nf.shp$NFSLANDU_2[match(treecov.dt$ID, nf.shp$ID)] # append forest name to each grid cell
setnames(treecov.dt, 'glad_treecover_2010_north_america_300m_aeac', 'treecov') 
setcolorder(treecov.dt, neworder = c('nf.name','ID','treecov'))

# classify as forest vs non-forest based on 10% tree cover threshold
treecov.dt[treecov >= 10, forest := 1]
treecov.dt[treecov < 10, forest := 0]

nf.dt$treecov <- treecov.dt$treecov
nf.dt$forest <- treecov.dt$forest 


# EXTRACT FOREST LAND SCAPE INTEGRITY VALUES FOR EACH NF ======================================
flii.dt <- data.table(extract(flii.r, nf.vec, df = T))
setnames(flii.dt, 'flii_nam_300m_aeac', 'flii') 
flii.dt[, flii := flii/1000] # scale so 0 - 10 as per Grantham et al. 2020
nf.dt$flii <- flii.dt$flii
rm(flii.dt)

# EXTRACT VEGETATION CARBON VALUES FOR EACH NF ================================================
agc.dt <- data.table(extract(agc.r, nf.vec, df = T))
setnames(agc.dt, 'aboveground_biomass_carbon_2010_MgChaX10_300m_aeac', 'agc.MgCha')
agc.dt[, agc.MgCha := agc.MgCha/10] # scale to Mg C / ha
agc.dt[, agc.MgCpxl := agc.MgCha * 9] # compute total biomass carbon per grid cell (there are 9 ha per 300 x 300 m grid cell)
nf.dt$agc.MgCha <- agc.dt$agc.MgCha
nf.dt$agc.MgCpxl <- agc.dt$agc.MgCpxl

bgc.dt <- data.table(extract(bgc.r, nf.vec, df = T))
setnames(bgc.dt, 'belowground_biomass_carbon_2010_MgChaX10_300m_aeac', 'bgc.MgCha')
bgc.dt[, bgc.MgCha := bgc.MgCha/10] # scale to Mg C / ha
bgc.dt[, bgc.MgCpxl := bgc.MgCha * 9] # compute total biomass carbon per grid cell (there are 9 ha per 300 x 300 m grid cell)
nf.dt$bgc.MgCha <- bgc.dt$bgc.MgCha
nf.dt$bgc.MgCpxl <- bgc.dt$bgc.MgCpxl

boc.dt <- data.table(extract(boc.r, nf.vec, df = T))
setnames(boc.dt, 'total_biomass_carbon_2010_MgChaX10_300m_aeac', 'boc.MgCha')
boc.dt[, boc.MgCha := boc.MgCha/10] # scale to Mg C / ha
boc.dt[, boc.MgCpxl := boc.MgCha * 9] # compute total biomass carbon per grid cell (there are 9 ha per 300 x 300 m grid cell)
nf.dt$boc.MgCha <- boc.dt$boc.MgCha
nf.dt$boc.MgCpxl <- boc.dt$boc.MgCpxl
rm(boc.dt)


# EXTRACT SOIL CARBON VALUES FOR EACH NF ================================================
soc.dt <- data.table(extract(soc.r, nf.vec, df = T))
setnames(soc.dt, 'X1', 'soc.MgCha')
soc.dt[, soc.MgCpxl := soc.MgCha * 9] # compute total C per grid cell (there are 9 ha per 300 x 300 m grid cell)
nf.dt$soc.MgCha <- soc.dt$soc.MgCha
nf.dt$soc.MgCpxl <- soc.dt$soc.MgCpxl
rm(soc.dt)


# COMPUTE TOTAL ECOSYSTEM CARBON DENSITY AND STOCKS
nf.dt[, totc.MgCha := boc.MgCha + soc.MgCha]
nf.dt[, totc.MgCpxl := boc.MgCpxl + soc.MgCpxl]


# EXTRACT FIRE DISTURBANCE VALUES FOR EACH NF ================================================
fire.dt <- data.table(extract(fire.r, nf.vec, df = T))
setnames(fire.dt, 'BurnDate', 'burned')
nf.dt$burned <- fire.dt$burned
rm(fire.dt)


# EXTRACT GAP STATUS CODES FOR EACH NF ================================================
gap.sts.dt <- data.table(extract(gap.sts.r, nf.vec, df = T))
setnames(gap.sts.dt, 'padus_gap_status_nam_300m_aeac', 'gap.sts')
nf.dt$gap.sts <- gap.sts.dt$gap.sts
nf.dt$gap.sts[is.na(nf.dt$gap.sts)] <- 4
rm(gap.sts.dt)


# EXTRACT FEDERAL MANGEMENT FLAG FOR EACH NF ================================================
fed.dt <- data.table(extract(fed.r, nf.vec, df = T))
setnames(fed.dt, 'padus_management_fed_nam_300m_aeac', 'fed')
nf.dt$fed <- fed.dt$fed
nf.dt$fed[is.na(nf.dt$fed)] <- 0
rm(fed.dt)


# WRITE OUT FOREST CONDITION CSV ========================================================================== 
fwrite(nf.dt, 'output/natl_forest_data_extraction.csv')
# nf.dt <- fread('output/natl_forest_data_extraction.csv')



# EXTRACT SPECIES DISTRIBUTION HABITAT FOR EACH NF ===========================================
habitat.file.names <- basename(habitat.files)
sp.df <- data.frame(matrix(unlist(strsplit(habitat.file.names, '_')), ncol = 4, byrow = T)[,1:2])
colnames(sp.df) <- c('sp.name','domain')
sp.df$file <- habitat.files

nf.habitat.list <- list()
for (i in 1:nrow(sp.df)){
  r <- rast(sp.df$file[i])
  dt <- data.table(exact_extract(r, nf.shp, 'count'))
  setnames(dt, 'V1','n.cells')
  dt$sp.name <- sp.df$sp.name[i]
  dt$domain <-  sp.df$domain[i]
  dt$nf.name <- nf.shp$NFSLANDU_2[match(1:nrow(dt), nf.shp$ID)] # append forest name to each grid cell
  nf.habitat.list[[i]] <- dt
}

nf.habitat.dt <- rbindlist(nf.habitat.list)
fwrite(nf.habitat.dt, 'output/natl_forest_habitat_data_extraction.csv')

# EXTRACT CLIMATE DATA FOR EACH NF =============================================
clim.meta.dt <- setDT(data.table::transpose(strsplit(basename(clim.files), '_')))
clim.meta.dt <- clim.meta.dt[, c(2,3,4)]
colnames(clim.meta.dt) <- c('variable','period','esm')
clim.meta.dt[esm == 'V.2.1.tif', esm := 'NA']
clim.meta.dt[, file := clim.files]

clim.list <- list()
for (i in 1:nrow(clim.meta.dt)){
  clim.r <- rast(clim.meta.dt$file[i])
  clim.dt <- data.table(extract(clim.r, nf.vec, df = T))
  colnames(clim.dt) <- c('ID','value')
  clim.dt$cell.id <- nf.dt$cell.id # add grid cell iD
  clim.dt$nf.name <- nf.shp$NFSLANDU_2[match(clim.dt$ID, nf.shp$ID)] # append forest name to each grid cell
  clim.dt$variable <- clim.meta.dt$variable[i]
  clim.dt$period <- clim.meta.dt$period[i]
  clim.dt$esm <- clim.meta.dt$esm[i]
  clim.list[[i]] <- clim.dt
  print(i)
}

clim.dt <- rbindlist(clim.list)
fwrite(clim.dt, 'output/natl_forest_climate_data_extraction.csv')

# END SCRIPT =================================================================================