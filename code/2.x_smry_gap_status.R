# SUMMARIZE CURRENT GAP STATUS FOR EACH NATIONAL FOREST
# Date: 2021-09-19
rm(list=ls())
require(data.table)
require(ggplot2)

# LOAD FILES =================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')

# SUMMARIZE ACROSS ALL LANDS ==================================================
nf.gap.smry.dt <- nf.dt[fed == 1, data.table(table(nf.name, gap.sts))] # this keeps combos with zero counts
nf.gap.smry.dt[, land.km2 := N * (300*300)/10^6]
nf.gap.smry.dt[, land.tot.km2 := sum(land.km2), by = 'nf.name']
nf.gap.smry.dt[, land.pcnt := round(land.km2/land.tot.km2*100, 1), by = 'nf.name']
nf.gap.smry.dt[, land.km2 := round(land.km2), by = 'nf.name']
nf.gap.smry.dt[, c('N','land.tot.km2') := NULL]
setorder(nf.gap.smry.dt, nf.name, gap.sts)

sak.nf.gap.smry.dt <- nf.gap.smry.dt[nf.name == "Tongass National Forest" | nf.name == "Chugach National Forest"]
sak.nf.gap.smry.dt

# SUMMARIZE ACROSS FOREST LANDS ==================================================
forest.nf.dt <- nf.dt[fed == 1 & forest == 1]
nf.forest.gap.smry.dt <- forest.nf.dt[, data.table(table(nf.name, gap.sts))] # this keeps combos with zero counts
nf.forest.gap.smry.dt[, forest.km2 := N * (300*300)/10^6]
nf.forest.gap.smry.dt[, forest.tot.km2 := sum(forest.km2), by = 'nf.name']
nf.forest.gap.smry.dt[, forest.pcnt := round(forest.km2/forest.tot.km2*100, 1), by = 'nf.name']
nf.forest.gap.smry.dt[, forest.km2 := round(forest.km2)]
nf.forest.gap.smry.dt[, c('N','forest.tot.km2') := NULL]
setorder(nf.forest.gap.smry.dt, nf.name, gap.sts)

sak.nf.forest.gap.smry.dt <- nf.forest.gap.smry.dt[nf.name == "Tongass National Forest" | nf.name == "Chugach National Forest"]
sak.nf.forest.gap.smry.dt


# SUMMARIZE FOREST CARBON LANDS ==================================================
nf.forest.carbon.gap.smry.dt <- forest.nf.dt[, .(totc.TgC = round(sum(totc.MgCpxl, na.rm=T)/10^6)), by = c('nf.name','gap.sts')]
nf.forest.carbon.gap.smry.dt[, totc.pcnt := round(totc.TgC/sum(totc.TgC)*100, 1), by = 'nf.name']
setorder(nf.forest.carbon.gap.smry.dt, nf.name, gap.sts)

sak.nf.forest.carbon.gap.smry.dt <- nf.forest.carbon.gap.smry.dt[nf.name == "Tongass National Forest" | nf.name == "Chugach National Forest"]
sak.nf.forest.carbon.gap.smry.dt

sak.nf.forest.carbon.gap.smry.dt <- rbind(data.table(nf.name = 'Chugach National Forest', gap.sts = 1, totc.TgC = 0, totc.pcnt = 0),
                                          sak.nf.forest.carbon.gap.smry.dt)

# COMBINE DATA SUMMARIES =========================================================
sak.nf.gap.smry.dt$forest.km2 <- sak.nf.forest.gap.smry.dt$forest.km2
sak.nf.gap.smry.dt$forest.pcnt <- sak.nf.forest.gap.smry.dt$forest.pcnt

sak.nf.gap.smry.dt <- cbind(sak.nf.gap.smry.dt, sak.nf.forest.carbon.gap.smry.dt[,3:4])

fwrite(sak.nf.gap.smry.dt, 'output/sak_natl_forest_gap_status_summary.csv')

require(dplyr)
require(sf)
nf.sf <- read_sf('data/admin/national_forests_aeac.shp')
xx <- nf.sf %>% filter(NFSLANDU_2 == 'Tongass National Forest' | NFSLANDU_2 == 'Chugach National Forest')
xx$GIS_ACRES/247.105

sak.nf.gap.smry.dt[, .(land.km2 = sum(land.km2), forest.km2 = sum(forest.km2)), by = 'nf.name']

sum(sak.nf.gap.smry.dt$land.km2)
