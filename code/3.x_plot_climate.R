# ANALYZE FOREST BURNED AREA ACROSS NATIONAL FORESTS 
# Date: 2021-09-19
rm(list=ls())
require(dplyr)
require(data.table)
require(ggplot2)
require(ggpubr)
setwd('A:/research/ecospatial/seak_preservation/')

# LOAD FILES =============================================================================
hist.clim.dt <- fread('output/natl_forest_historical_climate_summaries.csv')
fut.clim.dt <- fread('output/natl_forest_climate_summaries.csv')

# create labels
hist.clim.dt[, nf.label := nf.name]
hist.clim.dt[, nf.label := gsub(' National Forest','', nf.label)]

fut.clim.dt[, nf.label := nf.name]
fut.clim.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.hist.clim.dt <- hist.clim.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
seak.hist.clim.dt

seak.fut.clim.dt <- fut.clim.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
seak.fut.clim.dt

hist.clim.dt <- hist.clim.dt[nf.label != 'Tongass' | nf.label != 'Chugach']
fut.clim.dt <- fut.clim.dt[nf.label != 'Tongass' | nf.label != 'Chugach']


# PLOT HISTORICAL CLIMATE ACROSS NATIONAL FORESTS ============================
hist.fig <- ggplot(hist.clim.dt, aes(x=tmax.avg, y=ppt.avg, label = nf.label)) + 
  geom_point(shape = 21, color = 'gray50', fill = 'lightblue') + 
  geom_text(check_overlap = TRUE, hjust = -0.3, nudge_y= 0.02, alpha = 0.75, size = 2) + 
  geom_point(data = seak.hist.clim.dt, mapping = aes(x=tmax.avg, y=ppt.avg), 
             shape = 21, color = 'gray50', fill = 'red') + 
  # lims(x = c(13,36), y = c(300,4500)) + 
  labs(x = expression('Maximum temperature ('*degree*'C)'), 
       y =expression("Annual precipitation (mm)")) +
  theme_bw() + theme(axis.text=element_text(size=12), 
                     axis.title=element_text(size=14))

hist.fig

ggsave('figures/figure X climate normals.jpg', width = 6, height = 5, units = 'in', dpi = 400)


# PLOT FUTURE CLIMATE CHANGE ACROSS NATIONAL FORESTS ============================
fut.fig <- ggplot(fut.clim.dt, aes(x=change.med_bio5, y=change.med_bio12, label = nf.label)) + 
  # geom_pointrange(aes(ymin=change.min_bio12, ymax=change.max_bio12), color = 'gray80', alpha = 0.5, size = 0.1) +
  # geom_pointrange(aes(xmin=change.min_bio5, xmax=change.max_bio5), color = 'gray80', alpha = 0.5, size = 0.1) + 
  geom_point(shape = 21, color = 'gray50', fill = 'lightblue') + 
  geom_text(check_overlap = TRUE, hjust = -0.3, nudge_y= 0.02, alpha = 0.75, size = 2) + 
  geom_point(data = seak.fut.clim.dt, mapping = aes(x=change.med_bio5, y=change.med_bio12), 
             shape = 21, color = 'gray50', fill = 'red') + 
  # lims(x = c(3,10), y = c(-50,600)) + 
  labs(x = expression('Change in maximum temperature ('*degree*'C)'), 
       y =expression("Change in annual precipitation (mm)")) +
  theme_bw() + theme(axis.text=element_text(size=12), 
                     axis.title=element_text(size=14))
fut.fig

ggsave('figures/figure X climate change.jpg', width = 6, height = 5, units = 'in', dpi = 400)


# COMBINE HISTORICAL AND FUTURE FIGURES 
combo.fig <- ggarrange(hist.fig, fut.fig, ncol = 2, labels = c('(a)','(b)'), label.x = -0.025, label.y = 1)
combo.fig
ggsave('figures/figure X climate norms and changes.jpg', width = 8.5, height = 4.25, units = 'in', dpi = 400)

# END SCRIPT ==============================================================================================
