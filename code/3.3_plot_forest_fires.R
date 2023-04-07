# ANALYZE FOREST BURNED AREA ACROSS NATIONAL FORESTS 
# Date: 2021-09-19
rm(list=ls())
require(dplyr)
require(data.table)
require(ggplot2)

# LOAD FILES =============================================================================
nf.smry.dt <- fread('output/natl_forest_condition_summary.csv')

# total forest burned area across all NFs
sum(nf.smry.dt$burn.area.km2)
sum(nf.smry.dt$burn.area.km2, na.rm=T)/sum(nf.smry.dt$forest.area.km2, na.rm=T)*100

# subset AK NFs
seak.nf.smry.dt <- nf.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
nf.smry.dt <- nf.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

seak.nf.smry.dt
sum(seak.nf.smry.dt$forest.area.pcnt.all.nf)
sum(seak.nf.smry.dt$burn.area.pcnt.all.nf)

setorder(nf.smry.dt, burn.area.pcnt) 
nf.smry.dt

# PLOT MEAN FOREST CARBON DENSITY BY TOTAL CARBON STOCK ACROSS NATIONAL FORESTS ============================
ggplot(nf.smry.dt, aes(x=burn.area.km2, y=burn.area.pcnt, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.3, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = burn.area.pcnt.all.nf), shape = 21, color = 'gray50', fill = 'lightblue', show.legend = F) + 
  geom_point(data = nf.smry.dt, aes(x=burn.area.km2, y=burn.area.pcnt, label = nf.label, size = burn.area.pcnt.all.nf), 
              shape = 21, color = 'gray50', fill = NA) + 
  geom_point(data = seak.nf.smry.dt, mapping = aes(x=burn.area.km2, y=burn.area.pcnt, size = burn.area.pcnt.all.nf), 
             shape = 21, color = 'gray50', fill = 'red', show.legend = F) + 
  lims(x = c(0,4000)) + 
  labs(x = expression('Forest area burned 2001 to 2020 (km'^2*')'), y =expression("Forest area burned 2001 to 2020 (%)")) +
  scale_size(name = 'Percent of all forest burned in the NFS:', guide = guide_legend(ncol=6)) + 
  theme_bw() + theme(legend.position = c(0.7,0.1), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14))

ggsave('figures/figure X forest burned area.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# END SCRIPT ==============================================================================================
# percent of total burned area that occuren in SAK
sum(seak.nf.smry.dt$burn.pcnt.all.nf)