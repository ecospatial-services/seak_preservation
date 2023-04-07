# THIS R SCRIPT CREATES A MAP OF
# AUTHOR: LOGAN BERNER, NAU
# DATE: 2021-11-21
rm(list=ls())
require(ggplot2)
require(ggpubr)
require(sf)
require(raster)
require(data.table)
setwd('A:/research/ecospatial_services/seak_preservation/')

raster2spdf <- function(r, value.name){
  df <- as.data.frame(as(r, "SpatialPixelsDataFrame"))
  colnames(df) <- c(value.name, "x", "y")
  df
}

# LOAD FILES =================================================================================================================

# Boundary for Alaska
ak.sf <- st_read('../../data/boundaries/alaska_aaea.shp')

# ecosystem carbon
totc.r <- raster('data/biomass_carbon/total_biomass_carbon_2010_MgChaX10_300m_aeac.tif')/10

# forest landscape integrity
flii.r <- raster('data/forest_landscape_integrity/flii_nam_300m_aeac.tif')


# PREPARE DATA FOR MAPPING =======================================================================

# Convert shapefile and raster formats to what is needed for making maps with ggplot2.
# You'll need to do raster2spdf for the tree cover and land cover rasters as well
totc.spd <- raster2spdf(totc.r, value.name = 'totc.MgCha')
flii.spd <- raster2spdf(flii.r, value.name = 'flii')


# BASE MAP =================================================================================================

base.map <- ggplot() + 
  geom_sf(data=ak.sf, color = "gray10", size = 0.1, fill = "gray80") +
  guides(fill = guide_colourbar(title.position="top", title.hjust = 0.5)) +
  labs(x = '', y = '')
  # theme(axis.ticks.y = element_blank(),axis.text.y = element_blank(), # get rid of x ticks/text
  #       axis.ticks.x = element_blank(),axis.text.x = element_blank(), # get rid of y ticks/text
  #       legend.position="bottom", legend.box="horizontal", legend.key.width=unit(2, "cm"),
  #       legend.text=element_text(size=12), legend.title=element_text(size=14),
  #       plot.margin = unit(c(0.25,0.25,0.25,0.25), "cm")) 

base.map

# LST MAP ===========================================================================================
# color range to use for LST (see here for more colors: http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf)
lst.cols <- c('blue','yellow','orange','darkred') # you can add or remove colors here, but need atleast two

lst.avg.map <- base.map + # starting with the base map...
  geom_raster(data=lst.avg.spd, aes(x=x, y=y, fill=value), alpha=1) + # add the LST dat
  geom_sf(data=ny.sf, color = "black", size = 0.5, fill = NA) + # add the state outline
  scale_fill_gradientn(colours = lst.cols) + # specificy the color gradient
  labs(fill = expression('Average LSTmax from 2002-2020 ('*degree*'C)')) # add a label

lst.avg.map
ggsave('figures/modis_lst_maps.jpg', plot = lst.avg.map, width = 6, height = 5, units = 'in', dpi = 400)


# TREE COVER MAP =====================================================================================
treecov.cols <- c('','green','darkgreen') # you can add or remove colors here, but need atleast two

treecov.map <- base.map + # starting with the base map...
  geom_raster(data=treecov.spd, aes(x=x, y=y, fill=value), alpha=1) + # add the LST dat
  geom_sf(data=ny.sf, color = "black", size = 0.5, fill = NA) + # add the state outline
  scale_fill_gradientn(colours = treecov.cols, breaks = c(0,25,50,75,100),
                       labels = c(0,25,50,75,100), limits = c(0,100)) + # specificy the color gradient
  labs(fill = 'Tree cover (%)') # add a label

treecov.map

# LAND COVER MAP =====================================================================================
# Make a map of land cover...
lc.spd$landcover.name <- lc.key$landcover.name[match(lc.spd$value, lc.key$landcover.code)]
lc.spd$landcover.name <- factor(lc.spd$landcover.name, levels = c('Forest','Savanna','Grassland','Cropland','Urban','Other'))
lc.spd <- na.omit(lc.spd)

lc.key$landcover.name <- factor(lc.key$landcover.name, levels = c('Forest','Savanna','Grassland','Cropland','Urban','Other'))

lc.cols <- c('darkgreen','tan','yellow','darkorange3','gray20','gray80')

lc.map <- base.map + # starting with the base map...
  geom_raster(data=lc.spd, aes(x=x, y=y, fill=factor(landcover.name)), alpha=1, show.legend = T) +
  scale_fill_manual(values = lc.cols, labels = levels(lc.key$landcover.name), guide = T) +
  guides(fill = guide_legend(title="Land cover")) +
  geom_sf(data=ny.sf, color = "black", size = 0.5, fill = NA) +
  labs(fill = 'Land cover class') + 
  theme(legend.position="bottom")

lc.map


# COMBINE ALL OF THE MAPS TOGETHER =======================================================================
combo.map <- ggarrange(lst.avg.map, lst.avg.map, lst.avg.map, ncol = 3, nrow = 1)
ggsave('figures/modis_maps.jpg', plot = combo.map, width = 15, height = 8, units = 'in', dpi = 400)

# END SCRIPT ===========================================================================================

