# COMPARE ESTIMATES OF FOREST EXTENT AT 300 M VS 30 M SPATIAL RESOLUTION ACROSS NATIONAL FORESTS
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
require(ggpmisc)

# LOAD FILES AND SIMPLE PREP ===================================================
nf.shp <- st_read('data/admin/national_forests_aeac.shp')
forest.300m.r <- rast('data/tree_cover/glad_forestland_2010_north_america_300m_aeac.tif')
forest.30m.r <- rast('data/tree_cover/glad_forestland_2010_north_america_30m_aeac.tif')

# EXTRACT FOREST EXTENT FOR EACH NF AT BOTH RESOLUTIONS ========================
nf.smry.dt <- data.table(nf.name = nf.shp$NFSLANDU_2)
nf.smry.dt[, forest.cnt.300m := exact_extract(forest.300m.r, nf.shp, 'sum')]
nf.smry.dt[, forest.cnt.30m := exact_extract(forest.30m.r, nf.shp, 'sum')]

# CALCULATE FOREST AREA ========================================================
nf.smry.dt[, ':='(forest.km2.300m = forest.cnt.300m * 300^2 / 10^6,
                  forest.km2.30m = forest.cnt.30m * 30^2 / 10^6)]

nf.smry.dt[, pcnt.dif := (forest.km2.300m - forest.km2.30m) / (forest.km2.300m + forest.km2.30m)/2 * 100]

mean(nf.smry.dt$pcnt.dif, na.rm=T)
sd(nf.smry.dt$pcnt.dif, na.rm=T)

(sum(nf.smry.dt$forest.km2.300m) - sum(nf.smry.dt$forest.km2.30m)) / (sum(nf.smry.dt$forest.km2.300m) + sum(nf.smry.dt$forest.km2.30m))

(sum(nf.smry.dt$forest.km2.300m) - sum(nf.smry.dt$forest.km2.30m)) / sum(nf.smry.dt$forest.km2.30m) * 100



cor.test(nf.smry.dt$forest.km2.300m, nf.smry.dt$forest.km2.30m, method = 'spearman')

summary(lm(forest.km2.30m ~ forest.km2.300m, nf.smry.dt))

ggplot(nf.smry.dt, aes(forest.km2.300m, forest.km2.30m)) + 
  stat_poly_line() +
  stat_poly_eq(use_label(c("eq", "R2"))) + 
  geom_abline(color = 'gray50') + 
  geom_point(color = 'black', alpha = 0.5) + 
  xlim(0,55000) + ylim(0,55000) + 
  labs(x = expression('Forest area at 300 m resolution (km'^2*')'),
       y = expression('Forest area at 30 m resolution (km'^2*')'))

ggsave('figures/figure sx 300m vs 30 m forest area.jpg', width = 4, height = 4, units = 'in')
  
# write out tablur summary
fwrite(nf.smry.dt, 'output/natl_forest_extent_summary.csv')

