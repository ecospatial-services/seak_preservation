# SUMMARIZE AND PLOT FOREST INTEGRITY AND FOREST AREA FOR EACH NATIONAL FOREST
# Date: 2021-09-19
rm(list=ls())
require(data.table)
require(ggplot2)
setwd('A:/research/ecospatial_services/seak_preservation/')

# LOAD FILES =================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')
  
# IDENTIFY AREAS WITH HIGH FOREST INTEGRITY ==================================
flii.abv.thresh <- 9.6 # per Grantham et al. 2020

nf.dt[flii >= flii.abv.thresh, flii.high := 1]
nf.dt[flii < flii.abv.thresh, flii.high := 0]

# SUMMARIZE MEAN FLII AND TOTAL FOREST AREA FOR EACH NATIONAL FOREST =========
flii.smry.dt <- nf.dt[is.na(flii) == F, .(flii.q500 = quantile(flii, probs = 0.500), 
                                            flii.q250 = quantile(flii, probs = 0.250),
                                            flii.q750 = quantile(flii, probs = 0.750),
                                            flii.high.cnt = sum(flii.high),
                                            n.pxls = .N), by = nf.name]

flii.smry.dt[, area.km2 := n.pxls * (300*300) / (10^6)]
flii.smry.dt[, area.pcnt := round(area.km2/sum(area.km2)*100,1)]

flii.smry.dt[, flii.q500.rank := rank(-flii.q500)]
flii.smry.dt[, area.rank := rank(-area.km2)]
flii.smry.dt[, flii.high.pcnt := flii.high.cnt/sum(flii.high.cnt)*100]

# total forest area across all NFs 
sum(flii.smry.dt$area.km2)

setorder(flii.smry.dt, -flii.q500)
flii.smry.dt

setorder(flii.smry.dt, -area.km2)
flii.smry.dt

# create labels
flii.smry.dt[, nf.label := nf.name]
flii.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.flii.smry.dt <- flii.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
flii.smry.dt <- flii.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

# PLOT MEAN FOREST LANDSCAPE INTEGRITY INDEX BY TOTAL FOREST AREA ACROSS NATIONAL FORESTS ==========================
ggplot(flii.smry.dt, aes(x=area.km2, y=flii.q500, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = flii.high.pcnt), shape = 21, color = 'gray50', fill = 'lightblue') + 
  geom_point(data = seak.flii.smry.dt, mapping = aes(x=area.km2, y=flii.q500, size = flii.high.pcnt), 
             shape = 21, color = 'gray50', fill = 'red') + 
  lims(x = c(-500,50000), y = c(2.0,10.25)) + 
  labs(x = expression("Forest area (km"^2*')'), y ='Forest Landscape Integrity Index') +
  geom_hline(yintercept = c(6,9.6), linetype = 'dashed') + 
  annotate('text', -400, 4, label = "Low", size = 3, fontface = 2, angle = 90) +
  annotate('text', -400, 8, label = "Medium", size = 3, fontface = 2, angle = 90) +
  annotate('text', -400, 10, label = "High", size = 3, fontface = 2, angle = 90) +
  scale_size(name = 'Percent of all NF lands with high forest integrity:', guide = guide_legend(ncol=6)) + 
  theme_bw() + theme(legend.position = c(0.6,0.2), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14))
 
ggsave('figures/national_forest_intactness_vs_area.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# END SCRIPT =======================================================================================================