# DESCRIPTION ==================================================================
# This R script generates a two-panel figure showing tundra harvest field sites
# in (1) geographic space and (2) climate space. 
# Author: Logan Berner, NAU
# Date: 2022-06-08
# Notes: 

# SET UP =======================================================================
rm(list=ls())
require(data.table)
require(raster)
require(sf)
require(smoothr)
require(ggplot2)
require(ggnewscale)
require(ggpubr)

setwd('A:/research/ecospatial/seak_preservation/')

raster2spdf <- function(r){
  df <- as.data.frame(as(r, "SpatialPixelsDataFrame"))
  colnames(df) <- c("value", "x", "y")
  df
}

# LOAD SPATIAL DATA SETS ======================================================
usa.sf <- read_sf('A:/research/data/boundaries/USA_adm1.shp')
canada.sf <- read_sf('A:/research/data/boundaries/CAN_adm0.shp')
mexico.sf <- read_sf('A:/research/data/boundaries/MEX_adm0.shp')

eagle.ak.r <- raster('data/gap_habitat/9_final/baldeagle_alaska_60m_aeac.tif')
eagle.conus.r <- raster('data/gap_habitat/9_final/baldeagle_conus_60m_aeac.tif')

bear.ak.r <- raster('data/gap_habitat/9_final/brownbear_alaska_60m_aeac.tif')
bear.conus.r <- raster('data/gap_habitat/9_final/brownbear_conus_60m_aeac.tif')

eagle.ak.r <- raster('data/gap_habitat/9_final/baldeagle_alaska_60m_aeac.tif')
eagle.conus.r <- raster('data/gap_habitat/9_final/baldeagle_conus_60m_aeac.tif')

# PREPARE SPATIAL DATASETS ====================================================
sf_use_s2(F)
nam.aeac.crs <- crs('+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs')

usa.sf <- usa.sf %>% st_transform(nam.aeac.crs)
canada.sf <- canada.sf %>% st_transform(nam.aeac.crs)
mexico.sf <- mexico.sf %>% st_transform(nam.aeac.crs)

# land.sf <- land.sf %>% 
#   st_geometry() %>% 
#   st_crop(bbox) %>% 
#   smoothr::densify(max_distance = 10) %>% # add vertices so projection works
#   st_transform(crs = laea)


# CREATE MAP ==================================================================
base.map <- ggplot() + 
  geom_sf(data=usa.sf, fill = "gray30", color = "gray10", size = 0.05) + 
  geom_sf(data=canada.sf, fill = "gray70", color = NA) + 
  geom_sf(data=mexico.sf, fill = "gray70", color = NA) + 
  coord_sf(xlim = c(-4500000, 2194116), ylim = c(-1673582, 4500000), expand = FALSE) + 
  theme_bw() + 
  theme(axis.text=element_text(size=12))

base.map

eagle.spdf <- raster2spdf(eagle.ak.r)

xx <- base.map + geom_raster(data=eagle.spdf, aes(x=x, y=y), alpha=1) + scale_fill_discrete('red') 
ggsave('figures/test_map.jpg', plot = xx)  

clim.fig <- ggplot(arctic.clim.dt, aes(mat.C, ppt.mm)) +
  geom_hex(bins = 30) + 
  scale_fill_gradient(low="lemonchiffon2", high="gray30", limits=c(1000, NA), na.value = NA) +
  labs(x = expression('Mean annual temperature ('*degree*'C)'),
       y = 'Mean annual precipitation (mm)',
       fill = expression('Area (km'^2*')')) +
  new_scale_fill() + 
  geom_point(data = site.clim.dt, mapping = aes(mat.C, ppt.mm, fill = citation_short), 
             pch = 21, color = 'black', size = 2, alpha = 0.75) +
  # geom_point(data = site.clim.dt, mapping = aes(mat.C, ppt.mm), pch = 21, color = 'black', size = 2, alpha = 0.75) + 
  guides(fill = 'none') +
  lims(x = xlims, y=ylims) + 
  theme_bw() + 
  theme(legend.position = c(0.15, 0.65),
        legend.title = element_text(size=10), 
        legend.text = element_text(size=6),
        legend.key.height = unit(0.5,"cm"),
        axis.text = element_text(size=12),
        axis.title = element_text(size=14))

clim.fig

# ggsave('figures/fig1b_tundra_site_climate.jpg', 
#        width = 7, height = 6, units = 'in', dpi = 400)


# COMBINE SITE MAP AND CLIMATE FIGURES =========================================

site.map <- site.map + theme(legend.position = "none")

combo.fig <- ggarrange(site.map, clim.fig, labels=c('a','b'), align = 'h', 
                       ncol = 2, nrow = 1, label.x = 0.18, label.y = 0.97, 
                       font.label = list(size=18))

combo.wlegend.fig <- ggarrange(combo.fig, site.legend, nrow = 2, heights = c(0.6,0.3))
combo.wlegend.fig

ggsave('figures/fig1_tundra_sites.jpg', 
       width = 8, height = 6, units = 'in', dpi = 400)

# END SCRIPT ===================================================================