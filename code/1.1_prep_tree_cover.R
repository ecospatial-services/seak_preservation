# Date: 2022-1-02
rm(list=ls())
require(R.utils)
require(terra)
require(raster)
require(gdalUtilities)
require(gdalUtils)
setwd('A:/research/ecospatial/seak_preservation/')
mkdirs('data/tree_cover/')
mkdirs('data/tmp/tree_cover/')
wgs84.crs <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')
extnt <- c(-4000000,-1700000,2100000,4300000)

# Data citation:
# Hansen et al. 2013, High-Resolution Global Maps of 21st-Century Forest Cover Change: Science, v. 342, no. 6160, p. 850-853

# FILES TO DOWNLOAD ----------------------------------------------------------------
mkdirs('data/tmp/tree_cover/0_orig/')

# https://glad.umd.edu/dataset/global-2010-tree-cover-30-m
N <- paste0(c('00',seq(10,80,10)), 'N')
W <- paste0(c(paste0('0',seq(50,90,10)), seq(100,170,10)), 'W')
get.files <- expand.grid(N=N,W=W)
get.files$NW <- paste(get.files$N, get.files$W, sep='_')
get.files$name <- paste0('treecover2010_',get.files$NW,'.tif')
get.files$url <- paste0('https://glad.umd.edu/Potapov/TCC_2010/',get.files$name)
get.files$dest <- paste0('data/tmp/tree_cover/0_orig/',get.files$name)


# DOWNLOAD FILES -------------------------------------------------------------
# Some of the "tiles" above are fully in water and are not generated, hence use tryCatch to jump past errors 
for (i in 1:nrow(get.files)){
  skip_to_next <- FALSE
  tryCatch(downloadFile(url = get.files$url[i], filename = get.files$dest[i]), error = function(e) {skip_to_next <<- TRUE})
  if(skip_to_next) {next}     
  print(i/nrow(get.files))
}

# check output
rr <- rast(get.files$dest[11])
rr  
plot(rr)

# deleted by hand the empty tiles and those outside study domain 

# MOSAIC TILES ------------------------------------------------------------------
mkdirs('data/tmp/tree_cover/1_mosaic/')
files.in <- list.files('data/tmp/tree_cover/0_orig/', full.names = T)

mosaic_rasters(gdalfile = files.in, 
               dst_dataset = 'data/tmp/tree_cover/1_mosaic/glad_treecover_2010_north_america_30m_wgs84.tif',
               ot = "Byte")


# REPROJECT RASTER ------------------------------------------------------------------
mkdirs('data/tmp/tree_cover/2_proj/')

# 300 m resolution ---------------
gdalwarp(srcfile = 'data/tmp/tree_cover/1_mosaic/glad_treecover_2010_north_america_30m_wgs84.tif',
         dstfile = 'data/tree_cover/glad_treecover_2010_north_america_300m_aeac.tif',
         t_srs = as.character(nam.aeac.crs), 
         dstnodata = 254, r = 'average', tr = c(300,300), te = extnt, 
         ot = 'Byte', overwrite = T)

# check output
rr <- rast('data/tree_cover/glad_treecover_2010_north_america_300m_aeac.tif')
rr  
plot(rr)

# Identify forest lands
forest.r <- rr >= 10
writeRaster(forest.r, 'data/tree_cover/glad_forestland_2010_north_america_300m_aeac.tif')


# 30 m resolution ------------------- 
gdalwarp(srcfile = 'data/tmp/tree_cover/1_mosaic/glad_treecover_2010_north_america_30m_wgs84.tif',
         dstfile = 'data/tree_cover/glad_treecover_2010_north_america_30m_aeac.tif',
         t_srs = as.character(nam.aeac.crs), 
         dstnodata = 254, r = 'bilinear', tr = c(30,30), te = extnt, 
         ot = 'Byte', overwrite = T)

# check output
rr <- rast('data/tree_cover/glad_treecover_2010_north_america_30m_aeac.tif')
rr  
plot(rr)

# Identify forest lands
forest.r <- rr >= 10
writeRaster(forest.r, 'data/tree_cover/glad_forestland_2010_north_america_30m_aeac.tif')


# END SCRIPT ----------------------------------------------------------
# mkdirs('data/tmp/tree_cover/1_proj/')
# files.in <- list.files('data/tmp/tree_cover/0_orig/', full.names = T)
# file.out <- gsub('0_orig','1_proj', files.in)
# 
# for (i in 1:length(files.in)){  
#   gdalwarp(srcfile = files.in[i], dstfile = file.out[i], t_srs = as.character(nam.aeac.crs), 
#            dstnodata = 254, r = 'average', tr = c(300,300), # te = extnt, 
#            ot = 'Byte', overwrite = T)
# }
# 
# # check output
# rr <- rast(file.out[11])
# rr  
# plot(rr)
