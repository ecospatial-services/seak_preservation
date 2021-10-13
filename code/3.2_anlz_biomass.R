# Analyze vegetation carbon density and stocks for all National Forests
# Date: 2021-09-19
rm(list=ls())
require(R.utils)
require(dplyr)
require(data.table)
require(ggplot2)
setwd('A:/research/ecospatial_services/seak_preservation/')

# LOAD FILES =====================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')

# COMPUTE MEAN CARBON DENSITY AND TOTAL STOCK FOR EACH NATIONAL FOREST ===========
totc.smry.dt <- nf.dt[is.na(flii) == F, .(totc.med.MgCha = median(totc.MgCha), 
                            totc.avg.MgCha = mean(totc.MgCha),
                            totc.sd.MgCha = sd(totc.MgCha),
                            totc.sum.TgC = sum(totc.MgCpxl)/10^6),
                        by = nf.name]

totc.smry.dt[, totc.avg.MgCha.rank := rank(-totc.avg.MgCha)]
totc.smry.dt[, totc.sum.TgC.rank := rank(-totc.sum.TgC)]
totc.smry.dt[, totc.sum.TgC.pcnt := totc.sum.TgC/sum(totc.sum.TgC)*100]

setorder(totc.smry.dt, -totc.avg.MgCha)
totc.smry.dt

setorder(totc.smry.dt, -totc.sum.TgC)
totc.smry.dt

# mean and total forest biomass C across all NF lands
nf.overall.smry.dt <- nf.dt[is.na(flii) == F, .(totc.med.MgCha = median(totc.MgCha), 
                            totc.avg.MgCha = mean(totc.MgCha),
                            totc.sd.MgCha = sd(totc.MgCha),
                            totc.sum.TgC = sum(totc.MgCpxl)/10^6)]
nf.overall.smry.dt

# create labels
totc.smry.dt[, nf.label := nf.name]
totc.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.totc.smry.dt <- totc.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
totc.smry.dt <- totc.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

seak.totc.smry.dt

# PLOT MEAN FOREST CARBON DENSITY BY TOTAL CARBON STOCK ACROSS NATIONAL FORESTS ==================
ggplot(totc.smry.dt, aes(x=totc.sum.TgC, y=totc.avg.MgCha, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = totc.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'lightblue') + 
  geom_point(data = seak.totc.smry.dt, mapping = aes(x=totc.sum.TgC, y=totc.avg.MgCha, size = totc.sum.TgC.pcnt), 
             shape = 21, color = 'gray50', fill = 'red') + 
  lims(x = c(0,475)) + 
  labs(x = 'Total forest biomass carbon stock (Tg C)', y =expression("Forest biomass carbon density (Mg C ha"^-1*')')) +
  scale_size(name = 'Percent of all forest carbon stocks on NF lands:', guide = guide_legend(ncol=6)) + 
  theme_bw() + theme(legend.position = c(0.6,0.2), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14))

ggsave('figures/national_forest_carbon_density_vs_stock.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# HIGH INTEGRITY FORESTS : COMPUTE MEAN CARBON DENSITY AND TOTAL CARBON STOCK FOR EACH NATIONAL FOREST =======
totc.hi.flii.smry.dt <- nf.dt[flii >= 9.6, .(totc.med.MgCha = median(totc.MgCha), 
                                            totc.avg.MgCha = mean(totc.MgCha),
                                            totc.sd.MgCha = sd(totc.MgCha),
                                            totc.sum.TgC = sum(totc.MgCpxl)/10^6),
                        by = nf.name]
totc.hi.flii.smry.dt
totc.hi.flii.smry.dt[, totc.avg.MgCha.rank := rank(-totc.avg.MgCha)]
totc.hi.flii.smry.dt[, totc.sum.TgC.rank := rank(-totc.sum.TgC)]
totc.hi.flii.smry.dt[, totc.sum.TgC.pcnt := totc.sum.TgC/sum(totc.sum.TgC)*100]

setorder(totc.hi.flii.smry.dt, -totc.avg.MgCha)
totc.hi.flii.smry.dt

setorder(totc.hi.flii.smry.dt, -totc.sum.TgC)
totc.hi.flii.smry.dt

# create labels
totc.hi.flii.smry.dt[, nf.label := nf.name]
totc.hi.flii.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.totc.hi.flii.smry.dt <- totc.hi.flii.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
totc.hi.flii.smry.dt <- totc.hi.flii.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

# PLOT MEAN FOREST CARBON DENSITY BY TOTAL CARBON STOCK ACROSS NATIONAL FORESTS =============================
ggplot(totc.hi.flii.smry.dt, aes(x=totc.sum.TgC, y=totc.avg.MgCha, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = totc.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'lightblue') + 
  geom_point(data = seak.totc.hi.flii.smry.dt, mapping = aes(x=totc.sum.TgC, y=totc.avg.MgCha, size = totc.sum.TgC.pcnt), 
             shape = 21, color = 'gray50', fill = 'red') + 
  lims(x = c(0,410)) + 
  labs(x = 'Total biomass carbon stock in high integrity forests (Tg C)', 
       y = expression("Biomass carbon density \nin high integrity forests (Mg C ha"^-1*')')) +
  scale_size(name = 'Percent of all biomass carbon stocks \nin high integrity forests on NF lands:', guide = guide_legend(ncol=6)) + 
  theme_bw() + theme(legend.position = c(0.6,0.2), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14),
                     plot.margin = unit(c(1,1,1,1), "cm"))

ggsave('figures/national_forest_carbon_density_vs_stock_hi_flii.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# END SCRIPT =============================================================================================