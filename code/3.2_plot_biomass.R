# Analyze vegetation carbon density and stocks for all National Forests
# Date: 2021-09-19
rm(list=ls())
require(R.utils)
require(dplyr)
require(data.table)
require(ggplot2)
require(ggpubr)

# LOAD FILES =====================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')

# summarize across all forestlands w/in each NF
nf.smry.dt <- nf.dt[forest == 1 & fed == 1, .(boc.avg.MgCha = mean(boc.MgCha, na.rm=T),
                                               boc.sum.TgC = sum(boc.MgCpxl, na.rm=T)/10^6),
                    by = nf.name]

nf.smry.dt[, ':='(boc.avg.MgCha.rank = rank(-boc.avg.MgCha), 
                   boc.sum.TgC.rank = rank(-boc.sum.TgC),
                   boc.sum.TgC.pcnt = round(boc.sum.TgC/sum(boc.sum.TgC)*100))]


# summarize across intact forestlands w/in each NF
nf.intact.smry.dt <- nf.dt[forest == 1 & fed == 1 & flii >= 9.6, .(boc.intact.avg.MgCha = mean(boc.MgCha, na.rm=T),
                                                                    boc.intact.sum.TgC = sum(boc.MgCpxl, na.rm=T)/10^6),
                            by = nf.name]
nf.intact.smry.dt[, ':='(boc.intact.avg.MgCha.rank = rank(-boc.intact.avg.MgCha), 
                          boc.intact.sum.TgC.rank = rank(-boc.intact.sum.TgC),
                          boc.intact.sum.TgC.pcnt = round(boc.intact.sum.TgC/sum(boc.intact.sum.TgC)*100))]

# combine together
nf.smry.dt <- nf.intact.smry.dt[nf.smry.dt, on = 'nf.name']

nf.smry.dt[is.na(boc.intact.sum.TgC)]
           
nf.smry.dt[is.na(boc.intact.sum.TgC), boc.intact.sum.TgC := 0]
nf.smry.dt[is.na(boc.intact.avg.MgCha), boc.intact.avg.MgCha := 0]
nf.smry.dt[is.na(boc.intact.sum.TgC.pcnt), boc.intact.sum.TgC.pcnt := 0]

# create labels
nf.smry.dt[, nf.label := nf.name]
nf.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# subset AK NFs
seak.nf.smry.dt <- nf.smry.dt[nf.label == 'Tongass' | nf.label == 'Chugach']
seak.nf.smry.dt


# CREATE FIGURE ================================================================

fig1 <- ggplot(nf.smry.dt) +
  ggtitle("All forests") + 
  geom_text(data = nf.smry.dt, aes(x=boc.sum.TgC, y=boc.avg.MgCha, label = nf.label), check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) +
  geom_point(aes(x=boc.sum.TgC, y=boc.avg.MgCha, size = boc.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'lightblue', show.legend = F) +
  geom_point(data = seak.nf.smry.dt, mapping = aes(x=boc.sum.TgC, y=boc.avg.MgCha, size = boc.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'red', show.legend = F) +
  geom_point(data = nf.smry.dt, aes(x=boc.sum.TgC, y=boc.avg.MgCha, size = boc.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = NA) +
  lims(x = c(0,500), y = c(0, 160)) +
  labs(x = 'Total tree carbon stock (Tg C)', y =expression("Mean tree carbon density (Mg C ha"^-1*')')) + 
  scale_size(name = 'Percentage of all tree carbon in the NFS:', guide = guide_legend(ncol=6), breaks = seq(0,10,2.5)) + 
  theme_bw() + 
  theme(legend.position = c(0.65,0.1), legend.direction = 'vertical', legend.margin=margin(c(0,0,0,0)),
        legend.title = element_text(size=8), legend.text = element_text(size=8),
        axis.text=element_text(size=12), axis.title=element_text(size=14))


fig2 <- ggplot(nf.smry.dt) + 
  ggtitle("High integrity forests") + 
  geom_text(data = nf.smry.dt, aes(x=boc.intact.sum.TgC, y=boc.intact.avg.MgCha, label = nf.label), check_overlap = TRUE, hjust = -0.2, nudge_y= 0.02, alpha = 0.75, size = 3) +
  geom_point(aes(x=boc.intact.sum.TgC, y=boc.intact.avg.MgCha, size = boc.intact.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'lightblue', show.legend = F) +
  geom_point(data = seak.nf.smry.dt, aes(x=boc.intact.sum.TgC, y=boc.intact.avg.MgCha, size = boc.intact.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = 'red', show.legend = F) +
  geom_point(data = nf.smry.dt, aes(x=boc.intact.sum.TgC, y=boc.intact.avg.MgCha, size = boc.intact.sum.TgC.pcnt), shape = 21, color = 'gray50', fill = NA) +
  lims(x = c(0,500), y = c(0, 160)) +
  labs(x = 'Total tree carbon stock (Tg C)', y =expression("Mean tree carbon density (Mg C ha"^-1*')')) + 
  scale_size(name = 'Percentage of all tree carbon \n in high integrity forest in the NFS:', guide = guide_legend(ncol=6), breaks = seq(0,40,10)) + 
  theme_bw() + 
  theme(legend.position = c(0.65,0.1), legend.direction = 'vertical', legend.margin=margin(c(0,0,0,0)),
        legend.title = element_text(size=8), legend.text = element_text(size=8),
        axis.text=element_text(size=12), axis.title=element_text(size=14))

fig.combo <- ggarrange(fig1, fig2, ncol = 2, labels =  c('(a)','(b)'), font.label = 'bold')

fig.combo

ggsave('figures/figure 3 tree biomass carbon density vs stock.jpg', plot = fig.combo, width = 10, height = 5, units = 'in', dpi = 400)



# COMPARE AK NFs AGAINST OVERALL NF AVERAGE =======================================

overall.smry.dt <- nf.dt[forest == 1 & fed == 1, .(agc.tot.PgC = sum(agc.MgCpxl, na.rm=T)/10^9,
                                                   bgc.tot.PgC = sum(bgc.MgCpxl, na.rm=T)/10^9,
                                                   boc.total.PgC = sum(boc.MgCpxl, na.rm=T)/10^9,
                                                   boc.MgCha.avg = mean(boc.MgCha, na.rm=T),
                                                   boc.MgCha.sd = sd(boc.MgCha, na.rm=T))]

overall.smry.dt

(seak.nf.smry.dt$boc.avg.MgCha - overall.smry.dt$boc.MgCha.avg) / overall.smry.dt$boc.MgCha.avg * 100

sum(seak.nf.smry.dt$boc.sum.TgC)
seak.nf.smry.dt$boc.sum.TgC[2]/seak.nf.smry.dt$boc.sum.TgC[1]

# SCRATCH ======================================================================= 
nf.smry.dt[boc.intact.sum.TgC == 0]
# END SCRIPT =====================================================================