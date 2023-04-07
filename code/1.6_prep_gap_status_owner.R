# Download PRISM climate norms (1981-2010) for Alaska and the CONUS
# Date: 2021-08-15
rm(list=ls())
require(R.utils)
require(sf)
require(dplyr)
require(raster)
require(fasterize)
require(gdalUtilities)
require(data.table)
mkdirs('data/gap_pad/')

# See here for details about using PAD-US 2.1: 
# http://www.protectedlands.net/what-to-know-before-using-pad-us-version-2-0/

# Citation: 
# U.S. Geological Survey (USGS) Gap Analysis Project (GAP), 2020, 
# Protected Areas Database of the United States (PAD-US) 2.1: 
# U.S. Geological Survey data release, https://doi.org/10.5066/P92QM3NT.

# DOWNLOAD AND UNZIP FILES ---------------------------------------------------
# 1) Manually grabbed “PAD-US 2.1 File Geodatabase Download Package” file from https://www.sciencebase.gov/catalog/item/5f186a2082cef313ed843257
# 2) Put file in A:/research/data/admin/
# 3) Opened "PADUS2_1Combined_Fee_Designation_Easement" Geodatabase in QGIS 3.20
# 4) Ran Fix Geometries tool
# 5) Exported whole database with reprojection as a ESRI shapefile

# load files
padus.sf <- st_read('A:/research/data/admin/PAD_US3_GDB/pad_us_3_0_aeac.shp')
nf.sak.sf <- st_read('data/admin/southern_alaska_national_forests_aeac.shp')
flii.300m.r <- raster('data/forest_landscape_integrity/flii_nam_300m_aeac.tif')

colnames(padus.sf) <- tolower(colnames(padus.sf))

# GAP STATUS CODE FOR SEAK -----------------------------------------------------
# rasterize gap status code (minimum values when polygons overlay)
padus.sf$gap_sts <- as.numeric(padus.sf$gap_sts)
padus.gap.sts.300m.r <- fasterize(padus.sf, flii.300m.r, field = 'gap_sts', fun = 'min')
padus.gap.sts.300m.r
writeRaster(padus.gap.sts.300m.r, 'data/gap_pad/padus_gap_status_nam_300m_aeac.tif', overwrite=T)

# clip to southern Alaska 
padus.gap.sts.sak.300m.r <- raster::crop(padus.gap.sts.300m.r, nf.sak.sf)
padus.gap.sts.sak.300m.r <- raster::mask(padus.gap.sts.sak.300m.r, nf.sak.sf)
plot(padus.gap.sts.sak.300m.r)
writeRaster(padus.gap.sts.sak.300m.r, 'data/gap_pad/southern_alaska_padus_gap_status_nam_300m_aeac.tif', overwrite=T)

# MANAGEMENT TYPE --------------------------------------------------------------
# create key that matches management abbreviations with numbers 
mang.type.dt <- data.table(mang.abb = sort(unique(padus.sf$mang_type)))
mang.type.dt[, mang.code := 1:nrow(mang.type.dt)]
fwrite(mang.type.dt, 'data/gap_pad/padus_management_type_key.csv')

padus.sf$mang_type_code <- mang.type.dt$mang.code[match(padus.sf$mang_type, mang.type.dt$mang.abb)]
padus.mang.300m.r <- fasterize(padus.sf, flii.300m.r, field = 'mang_type_code')
writeRaster(padus.mang.300m.r, 'data/gap_pad/padus_management_type_nam_300m_aeac.tif', overwrite=T)

# identify federally managed lands
fed.mang.300m.r <- padus.mang.300m.r == 2
writeRaster(fed.mang.300m.r, 'data/gap_pad/padus_management_fed_nam_300m_aeac.tif', overwrite=T)

# clip management type and federally managed lands to southern Alaska 
padus.mang.sak.300m.r <- raster::crop(padus.mang.300m.r, nf.sak.sf)
padus.mang.sak.300m.r <- raster::mask(padus.mang.sak.300m.r, nf.sak.sf)
plot(padus.mang.sak.300m.r)
writeRaster(padus.mang.sak.300m.r, 'data/gap_pad/southern_alaska_padus_mangement_type_nam_300m_aeac.tif', overwrite=T)

fed.sak.300m.r <- padus.mang.sak.300m.r == 2
plot(padus.mang.sak.300m.r)
writeRaster(fed.sak.300m.r, 'data/gap_pad/southern_alaska_padus_mangement_fed_nam_300m_aeac.tif', overwrite=T)
