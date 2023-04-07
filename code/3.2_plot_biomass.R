# Analyze vegetation carbon density and stocks for all National Forests
# Date: 2021-09-19
rm(list=ls())
require(R.utils)
require(dplyr)
require(data.table)
require(ggplot2)

# LOAD FILES =====================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')
nf.smry.dt <- fread('output/natl_forest_condition_summary.csv')



# create labels
nf.smry.dt[, nf.label := nf.name]
nf.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]
setorder(nf.smry.dt, boc.avg.MgCha)
nf.smry.dt

setorder(nf.smry.dt, boc.sum.TgC)
nf.smry.dt

# subset AK NFs
seak.nf.smry.dt <- nf.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
seak.nf.smry.dt

# compare AK NF's against overall NF average
overall.smry.dt <- nf.dt[forest == 1 & fed == 1, .(agc.tot.PgC = sum(agc.MgCpxl, na.rm=T)/10^9,
                                     bgc.tot.PgC = sum(bgc.MgCpxl, na.rm=T)/10^9,
                                     boc.total.PgC = sum(boc.MgCpxl, na.rm=T)/10^9,
                                     boc.MgCha.avg = mean(boc.MgCha, na.rm=T),
                                     boc.MgCha.sd = sd(boc.MgCha, na.rm=T))]

overall.smry.dt

(seak.nf.smry.dt$boc.avg.MgCha - overall.smry.dt$boc.MgCha.avg) / overall.smry.dt$boc.MgCha.avg * 100

sum(seak.nf.smry.dt$agc.sum.TgC)
sum(seak.nf.smry.dt$boc.sum.TgC)
seak.nf.smry.dt$boc.sum.TgC[2]/seak.nf.smry.dt$boc.sum.TgC[1]

# PLOT MEAN FOREST CARBON DENSITY BY TOTAL CARBON STOCK ACROSS NATIONAL FORESTS ==================
ggplot(nf.smry.dt, aes(x=boc.sum.TgC, y=boc.avg.MgCha, label = nf.label)) + 
  geom_text(check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) + 
  geom_point(aes(size = boc.sum.TgC.pcnt.all.nf), shape = 21, color = 'gray50', fill = 'lightblue', show.legend = F) + 
  geom_point(data = seak.nf.smry.dt, mapping = aes(x=boc.sum.TgC, y=boc.avg.MgCha, size = boc.sum.TgC.pcnt.all.nf), 
             shape = 21, color = 'gray50', fill = 'red', show.legend = F) + 
  geom_point(data = nf.smry.dt, aes(x=boc.sum.TgC, y=boc.avg.MgCha, label = nf.label, size = boc.sum.TgC.pcnt.all.nf), 
             shape = 21, color = 'gray50', fill = NA) + 
  lims(x = c(0,500)) + 
  labs(x = 'Total tree biomass carbon stock (Tg C)', y =expression("Mean tree biomass carbon density (Mg C ha"^-1*')')) +
  scale_size(name = 'Percentage of total tree biomass carbon stock in the NFS:', 
             guide = guide_legend(ncol=6), breaks = seq(0,10,2.5)) + 
  theme_bw() + theme(legend.position = c(0.6,0.2), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14))

ggsave('figures/figure 3 tree biomass carbon density vs stock.jpg', width = 8, height = 5, units = 'in', dpi = 400)


# HIGH INTEGRITY FORESTS : COMPUTE MEAN CARBON DENSITY AND TOTAL CARBON STOCK FOR EACH NATIONAL FOREST =======
boc.hi.flii.smry.dt <- nf.dt[flii >= 9.6, .(boc.avg.MgCha = mean(boc.MgCha, na.rm=T),
                                             boc.sum.TgC = sum(boc.MgCpxl, na.rm=T)/10^6),
                              by = nf.name]
boc.hi.flii.smry.dt
boc.hi.flii.smry.dt[, boc.avg.MgCha.rank := rank(-boc.avg.MgCha)]
boc.hi.flii.smry.dt[, boc.sum.TgC.rank := rank(-boc.sum.TgC)]
boc.hi.flii.smry.dt[, boc.sum.TgC.pcnt := round(boc.sum.TgC/sum(boc.sum.TgC)*100)]

setorder(boc.hi.flii.smry.dt, -boc.avg.MgCha)
boc.hi.flii.smry.dt

setorder(boc.hi.flii.smry.dt, -boc.sum.TgC)
boc.hi.flii.smry.dt

# create labels
boc.hi.flii.smry.dt[, nf.label := nf.name]
boc.hi.flii.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.boc.hi.flii.smry.dt <- boc.hi.flii.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
boc.hi.flii.smry.dt <- boc.hi.flii.smry.dt[nf.label != 'Tongass' | nf.label != 'Chugach']

# PLOT MEAN FOREST CARBON DENSITY BY TOTAL CARBON STOCK ACROSS NATIONAL FORESTS =============================
ggplot(boc.hi.flii.smry.dt, aes(x=boc.sum.TgC, y=boc.avg.MgCha, label = nf.label)) +
  geom_text(check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) +
  geom_point(aes(size = boc.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'lightblue', show.legend = F) +
  geom_point(data = seak.boc.hi.flii.smry.dt, mapping = aes(x=boc.sum.TgC, y=boc.avg.MgCha, size = boc.sum.TgC.pcnt),
             shape = 21, color = 'gray50', fill = 'red', show.legend = F) +
  geom_point(data = boc.hi.flii.smry.dt, mapping = aes(x=boc.sum.TgC, y=boc.avg.MgCha, label = nf.label, size = boc.sum.TgC.pcnt), 
             shape = 21, color = 'gray50', fill = NA) +
  lims(x = c(0,400)) +
  labs(x = 'Total tree biomass carbon stock in high integrity forests (Tg C)', 
       y = expression("Mean tree biomass carbon density \nin high integrity forests (Mg C ha"^-1*')')) +
  scale_size(name = 'Percentage of total tree biomass carbon stock \nin high integrity forests in the NFS:', guide = guide_legend(ncol=6)) +
  theme_bw() + theme(legend.position = c(0.6,0.2), legend.direction = 'vertical',
                     axis.text=element_text(size=12), axis.title=element_text(size=14),
                     plot.margin = unit(c(1,1,1,1), "cm"))

ggsave('figures/figure 4 tree biomass carbon density vs stock in high integrity forest.jpg', width = 8, height = 5, units = 'in', dpi = 400)

# END SCRIPT =============================================================================================