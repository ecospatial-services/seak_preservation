# CURRENT HABITAT FOR WOLVES, BEARS, AND EAGLES ACROSS NATIONAL FORESTS 
# Date: 2021-09-19
rm(list=ls())
require(dplyr)
require(data.table)
require(ggplot2)
require(egg) # for tag_facet() 
require(tidytext) # for reorder_within()
setwd('A:/research/ecospatial_services/seak_preservation/')

# LOAD FILES =============================================================================
nf.habitat.dt <- fread('output/natl_forest_habitat_data_extraction.csv')

# summarize 
nf.habitat.dt <- nf.habitat.dt[, .(n.cells = sum(n.cells)), by = c('nf.name','sp.name')]
nf.habitat.dt[, area.km2 := n.cells * 60^2 / 10^6]
nf.habitat.dt[, sp.area.km2 := sum(area.km2), by = c('sp.name')]
nf.habitat.dt[, sp.area.pcnt := round(area.km2 / sp.area.km2 * 100)]
nf.habitat.dt[, sp.area.pcnt.lab := paste0(sp.area.pcnt,'%')]
nf.habitat.dt[, sp.area.rank := rank(-sp.area.pcnt), by = c('sp.name')]

# total species habitat across all NFs 


# create labels
nf.habitat.dt[, nf.label := nf.name]
nf.habitat.dt[, nf.label := factor(gsub(' National Forest','', nf.label))]

# select top N NFs with most habitat for each species  
nf.habitat.dt <- data.table(nf.habitat.dt, key = "area.km2")
nf.habitat.topN.dt <- nf.habitat.dt[, tail(.SD, 5), by = c('sp.name')]

# set factors
nf.habitat.topN.dt[, sp.name := factor(sp.name, levels = c('baldeagle','brownbear','graywolf'), 
                                       labels = c('Bald eagle','Brown bear','Gray wolf'))]
# nf.habitat.topN.dt$sp.name <- factor(nf.habitat.topN.dt$sp.name, labels = c('Bald eagle','Brown bear','Gray wolf'))
  
# set order 
nf.habitat.topN.dt <- setorder(nf.habitat.topN.dt, sp.name, -area.km2)
nf.habitat.topN.dt

# nf.habitat.topN.dt[, nf.name := reorder_within(nf.name, area.km2, sp.name)]
nf.habitat.topN.dt <- nf.habitat.topN.dt %>% mutate(nf.label = reorder_within(nf.label, area.km2, sp.name))
  
# PLOT HABITAT EXTENT FOR EACH TOP NATIONAL FOREST ============================
habitat.fig <- ggplot(nf.habitat.topN.dt, aes(x=nf.label, y=area.km2)) + 
  facet_wrap(~sp.name, nrow = 3, scales = "free_y") + 
  coord_flip() + 
  scale_x_reordered() +
  scale_y_continuous(limits = c(0, 46000), expand = c(0,0)) + 
  geom_bar(stat = "identity") + 
  geom_text(aes(label = sp.area.pcnt.lab), position = position_dodge(width = 1), hjust = -0.25, vjust = 0.25, color = 'black', size = 3) + 
  theme_bw() + theme(axis.text=element_text(size=12), 
                     axis.title=element_text(size=14),
                     strip.text=element_text(size=12)) + 
  labs(x = "", y = expression('Habitat extent (km'^2*')'))

habitat.fig

# tag_facet(habitat.fig, open = '', close = '', x = 4, y = 20, vjust = 0.75, size = 5)

ggsave('figures/figure X habitat extent.jpg', width = 4, height = 6, units = 'in', dpi = 400)

# END SCRIPT ==============================================================================================



