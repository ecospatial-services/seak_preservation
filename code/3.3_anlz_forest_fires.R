# ANALYZE FOREST BURNED AREA ACROSS NATIONAL FORESTS 
# Date: 2021-09-19
rm(list=ls())
require(dplyr)
require(data.table)
require(ggplot2)
setwd('A:/research/ecospatial_services/seak_preservation/')

# LOAD FILES =============================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')

# COMPUTE TOTAL FOREST BURNED AREA AND % BURNED FOR EACH  NATIONAL FOREST ================
n.yrs <- 20
burn.smry.dt <- nf.dt[is.na(flii) == F, .(burn.pxls = sum(burned),
                                          area.pxls = .N), by = nf.name]
burn.smry.dt[, ':='(burn.km2 = burn.pxls * (300*300) / (10^6),
                    area.km2 = area.pxls * (300*300) / (10^6))]

burn.smry.dt[, burn.pcnt := (burn.km2/area.km2)*100]
burn.smry.dt[, burn.pcnt.rank := rank(-burn.pcnt)]
burn.smry.dt[, burn.pcnt.rank.pcnt := percent_rank(burn.pcnt)]
burn.smry.dt[, burn.area.rank.pcnt := percent_rank(burn.km2)]
burn.smry.dt[, burn.pcnt.all.nf := burn.km2 / sum(burn.km2)*100]

burn.smry.dt

# total forest burned area across all NFs
sum(burn.smry.dt$burn.km2)
sum(burn.smry.dt$burn.km2)/sum(burn.smry.dt$area.km2)*100


# create labels
burn.smry.dt[, nf.label := nf.name]
burn.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.burn.smry.dt <- burn.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
burn.smry.dt <- burn.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

seak.burn.smry.dt

# PLOT MEAN FOREST CARBON DENSITY BY TOTAL CARBON STOCK ACROSS NATIONAL FORESTS ============================
ggplot(burn.smry.dt, aes(x=burn.km2, y=burn.pcnt, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.3, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = burn.pcnt.all.nf), shape = 21, color = 'gray50', fill = 'lightblue') + 
  geom_point(data = seak.burn.smry.dt, mapping = aes(x=burn.km2, y=burn.pcnt, size = burn.pcnt.all.nf), 
             shape = 21, color = 'gray50', fill = 'red') + 
  lims(x = c(0,3500)) + 
  labs(x = expression('Forest area burned 2001 to 2020 (km'^2*')'), y =expression("Forest area burned 2001 to 2020 (%)")) +
  scale_size(name = 'Percent of all forest burned on NF lands:', guide = guide_legend(ncol=6)) + 
  theme_bw() + theme(legend.position = c(0.7,0.1), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14))

ggsave('figures/national_forest_burned_area.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# END SCRIPT ==============================================================================================

# percent of total burned area that occuren in SAK
sum(seak.burn.smry.dt$burn.pcnt.all.nf)
