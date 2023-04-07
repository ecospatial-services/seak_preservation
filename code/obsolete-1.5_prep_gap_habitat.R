# Download and project USFS administrative boundaries of various kinds (National Forests, Wilderness Areas, ...)
# Date: 2021-08-15
# Author: Logan Berner, EcoSpatial Services LLC
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
require(gdalUtilities)

setwd('A:/research/ecospatial/seak_preservation/')
mkdirs('data/gap_habitat/')
mkdirs('data/gap_habitat/0_tmp/')
mkdirs('data/gap_habitat/1_zips/')
mkdirs('data/gap_habitat/2_unzips/')
mkdirs('data/gap_habitat/9_final/')

# FILES TO DOWNLOAD ----------------------------------------------------------
ak.sp.df <- data.frame(sp.name = c('baldeagle','graywolf','brownbear'),
                    domain = c('alaska','alaska','alaska'),
                    url = c('http://akgap.uaa.alaska.edu/distribution/BaldEagle_BreedingDistribution.zip',
                            'http://akgap.uaa.alaska.edu/distribution/Wolf_AnnualDistribution.zip',
                            'http://akgap.uaa.alaska.edu/distribution/BrownBear_AnnualDistribution.zip'))
                    
conus.sp.df <- data.frame(sp.name = c('eagle','wolf','brownbear'),
                       domain = c('conus','conus','conus'),
                       url = c('https://www.sciencebase.gov/catalog/file/get/58fa4517e4b0b7ea54524ca5',
                               'https://www.sciencebase.gov/catalog/file/get/58fa69c2e4b0b7ea545258bb',
                               'https://www.sciencebase.gov/catalog/file/get/58fa625ae4b0b7ea5452576d'))


# DOWNLOAD AND UNZIP FILES ---------------------------------------------------
# NOTE: The species distribution data for the CONUS were downloaded and unzipped by hand because
# the files downloaded via R could not be unzipped because they were 'corrupt.' 

for (i in 1:nrow(ak.sp.df)){

  # download file
  dl.file <- paste0('data/gap_habitat/1_zips/', ak.sp.df$sp.name[i], '_', ak.sp.df$domain[i],'.zip')
  download.file(ak.sp.df$url[i], destfile = dl.file)
  
  # unzip files
  unzip(dl.file, exdir = 'data/gap_habitat/0_tmp', overwrite = T)
  
  # move file
  in.file <- list.files('data/gap_habitat/0_tmp/', pattern = glob2rx('*.img'), full.names = T)
  out.file <- paste0('data/gap_habitat/2_unzips/', ak.sp.df$sp.name[i], '_', ak.sp.df$domain[i],'.img')
  file.rename(from = in.file, to = out.file)
  
  # delete temporary files
  unlink(c(in.file))
  print(paste0('finished ', ak.sp.df$sp.name[i], ' ', ak.sp.df$domain[i]))
}

# REPROJECT ----------------------------------------------------------
# https://guides.library.duke.edu/r-geospatial/CRS
nad83.crs <- CRS('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs')
nam.aeac.crs <- CRS('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')

sp.files <- list.files('data/gap_habitat/2_unzips/', full.names = T)
sp.files.names <- list.files('data/gap_habitat/2_unzips/', full.names = F)

sp.files <- sp.files[c(2,4,6)]
sp.files.names <- sp.files.names[c(2,4,6)]

for (i in 1:length(sp.files)){
  domain <- substr(sp.files.names[i], nchar(sp.files.names[i])-9, nchar(sp.files.names[i])-4)
  if (domain == 'alaska'){
    out.file <- paste0('data/gap_habitat/9_final/', gsub('.img','_60m_aeac.tif', sp.files.names[i]))
    ak.extent <- c(-4500000, 2000000, -1800000, 4500000)
    gdalwarp(srcfile = sp.files[i], dstfile = out.file, t_srs = 'ESRI:102008', r = 'near', tr = c(60,60), te = ak.extent, ot = 'Byte', overwrite = T)      
  } else {
    out.file <- paste0('data/gap_habitat/9_final/', gsub('.tif','_60m_aeac.tif', sp.files.names[i]))
    #gdalwarp(srcfile = sp.files[i], dstfile = out.file, t_srs = 'ESRI:102008', r = 'near', tr = c(60,60), overwrite = T) #, ot = 'Byte')      
    conus.extent <- c(-2289684, -1673582, 2194116, 1378498)
    gdalwarp(srcfile = sp.files[i], dstfile = out.file, t_srs = 'ESRI:102008', r = 'near', tr = c(60,60), te = conus.extent, overwrite = T) #, ot = 'Byte')      
  }
  
  print(paste0('fisished ', sp.files.names[i]))
}

# CALCULATE OVERLAP OF EAGLE, WOLF, AND BEAR HABITAT ---------------------------
bear.ak.r <- rast('data/gap_habitat/9_final/brownbear_alaska_60m_aeac.tif')
eagle.ak.r <- rast('data/gap_habitat/9_final/baldeagle_alaska_60m_aeac.tif')
wolf.ak.r <- rast('data/gap_habitat/9_final/graywolf_alaska_60m_aeac.tif')
overlap.ak.r <- bear.ak.r * eagle.ak.r * wolf.ak.r
writeRaster(overlap.ak.r, 'data/gap_habitat/9_final/overlap_alaska_60m_aeac.tif')

bear.conus.r <- rast('data/gap_habitat/9_final/brownbear_conus_60m_aeac.tif')
eagle.conus.r <- rast('data/gap_habitat/9_final/baldeagle_conus_60m_aeac.tif')
wolf.conus.r <- rast('data/gap_habitat/9_final/graywolf_conus_60m_aeac.tif')
overlap.conus.r <- bear.conus.r * eagle.conus.r * wolf.conus.r
overlap.conus.r <- classify(overlap.conus.r, c(1, 28, 1))
writeRaster(overlap.conus.r, 'data/gap_habitat/9_final/overlap_conus_60m_aeac.tif', overwrite=T)

# END SCRIPT ---------------------------------------------------------------