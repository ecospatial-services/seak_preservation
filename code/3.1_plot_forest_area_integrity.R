# SUMMARIZE AND PLOT FOREST INTEGRITY AND FOREST AREA FOR EACH NATIONAL FOREST
# Date: 2021-09-19
rm(list=ls())
require(data.table)
require(ggplot2)

# LOAD FILES =================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')
nf.smry.dt <- fread('output/natl_forest_condition_summary.csv')  
nf.smry.dt <- na.omit(nf.smry.dt)

# PREPARE FOR GRAPHING ======================================================   

# subset AK NFs
seak.smry.dt <- nf.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
seak.smry.dt

sum(seak.smry.dt$forest.area.km2)
sum(nf.smry.dt$forest.area.km2, na.rm = T)

setorder(nf.smry.dt, flii.avg.rank)
nf.smry.dt

# PLOT MEAN FOREST LANDSCAPE INTEGRITY INDEX BY TOTAL FOREST AREA ACROSS NATIONAL FORESTS ==========================
ggplot(nf.smry.dt, aes(x=forest.area.km2, y=flii.avg, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = flii.high.pcnt.all.nf), 
             shape = 21, color = 'gray50', fill = 'lightblue', show.legend = F) +
  geom_point(data = seak.smry.dt, mapping = aes(x=forest.area.km2, y=flii.avg, size = flii.high.pcnt.all.nf),
             shape = 21, color = 'gray50', fill = 'red', show.legend = F) +
  geom_point(data = nf.smry.dt, aes(x=forest.area.km2, y=flii.avg, size = flii.high.pcnt.all.nf), 
             shape = 21, color = 'gray50', fill = NA) + 
  lims(x = c(-1500,60000), y = c(3.0,10.25)) + 
  labs(x = expression("Forest area (km"^2*')'), y ='Mean Forest Landscape Integrity Index') +
  geom_hline(yintercept = c(6,9.6), linetype = 'dashed') + 
  annotate('text', -1400, 4.5, label = "Low", size = 3, fontface = 2, angle = 90) +
  annotate('text', -1400, 8, label = "Medium", size = 3, fontface = 2, angle = 90) +
  annotate('text', -1400, 10, label = "High", size = 3, fontface = 2, angle = 90) +
  scale_size(name = 'Percentage of all high integrity forest in the NFS:', 
             guide = guide_legend(ncol=7), breaks = seq(0,30,5))+ 
  theme_bw() + theme(legend.position = c(0.6,0.2), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14))

ggsave('figures/figure 2 forest intactness vs area.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# SUMMARY STATISTICS ===============================================================
nf.dt[fed == 1, .(flii.avg = mean(flii, na.rm=T),
                  flii.sd = sd(flii, na.rm=T))]


# END SCRIPT =======================================================================================================
nf.smry.dt <- nf.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

