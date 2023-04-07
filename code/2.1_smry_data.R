# SUMMARIZE AND PLOT FOREST INTEGRITY AND FOREST AREA FOR EACH NATIONAL FOREST
# Date: 2022-01-08
rm(list=ls())
require(data.table)
require(ggplot2)

# LOAD FILES =================================================================
nf.dt <- fread('output/natl_forest_data_extraction.csv')
clim.dt <- fread('output/natl_forest_climate_data_extraction.csv')

# IDENTIFY AREAS WITH HIGH FOREST INTEGRITY ==================================
flii.abv.thresh <- 9.6 # per Grantham et al. 2020
nf.dt[flii >= flii.abv.thresh, flii.high := 1]
nf.dt[flii < flii.abv.thresh, flii.high := 0]

# SUMMARIZE FOREST CONDITIONS FOR EACH NATIONAL FOREST =========================

# forest area --------------------------------------------
nf.smry.dt <- nf.dt[forest == 1 & fed == 1, .(forest.area.km2 = round(sum(forest)*(300*300)/10^6)), by = nf.name]
nf.smry.dt[, forest.area.pcnt.all.nf := round(forest.area.km2/sum(forest.area.km2, na.rm=T)*100,1)]
nf.smry.dt[, forest.area.rank := rank(-forest.area.km2)]

# create labels -------------------------------------------
nf.smry.dt[, nf.label := nf.name]
nf.smry.dt[, nf.label := gsub(' National Forest','', nf.label)]

# forest aboveground carbon stocks -----------------------------
agc.smry.dt <- nf.dt[forest == 1 & fed == 1, .(agc.avg.MgCha = round(mean(agc.MgCha, na.rm=T)), 
                                               agc.q95.MgCha = round(quantile(agc.MgCha, 0.95, na.rm=T)),
                                               agc.sd.MgCha = round(sd(agc.MgCha, na.rm=T)),
                                               agc.sum.TgC = round(sum(agc.MgCpxl, na.rm=T)/10^6,1)), 
                     by = nf.name]
agc.smry.dt[, agc.avg.MgCha.rank := rank(-agc.avg.MgCha)]
agc.smry.dt[, agc.sum.TgC.rank := rank(-agc.sum.TgC)]
agc.smry.dt[, agc.sum.TgC.pcnt.all.nf := round(agc.sum.TgC/sum(agc.sum.TgC)*100,1)]
agc.smry.dt

# forest aboveground carbon stocks -----------------------------
bgc.smry.dt <- nf.dt[forest == 1 & fed == 1, .(bgc.avg.MgCha = round(mean(bgc.MgCha, na.rm=T)),
                                               bgc.q95.MgCha = round(quantile(bgc.MgCha, 0.95, na.rm=T)),
                                               bgc.sd.MgCha = round(sd(bgc.MgCha, na.rm=T)),
                                               bgc.sum.TgC = round(sum(bgc.MgCpxl, na.rm=T)/10^6,1)), 
                     by = nf.name]
bgc.smry.dt[, bgc.avg.MgCha.rank := rank(-bgc.avg.MgCha)]
bgc.smry.dt[, bgc.sum.TgC.rank := rank(-bgc.sum.TgC)]
bgc.smry.dt[, bgc.sum.TgC.pcnt.all.nf := round(bgc.sum.TgC/sum(bgc.sum.TgC)*100,1)]
bgc.smry.dt

# forest biomass carbon stocks -----------------------------
boc.smry.dt <- nf.dt[forest == 1 & fed == 1, .(boc.avg.MgCha = round(mean(boc.MgCha, na.rm=T)), 
                                     boc.sd.MgCha = round(sd(boc.MgCha, na.rm=T)),
                                     boc.sum.TgC = round(sum(boc.MgCpxl, na.rm=T)/10^6,1)), 
                      by = nf.name]
boc.smry.dt[, boc.avg.MgCha.rank := rank(-boc.avg.MgCha)]
boc.smry.dt[, boc.sum.TgC.rank := rank(-boc.sum.TgC)]
boc.smry.dt[, boc.sum.TgC.pcnt.all.nf := round(boc.sum.TgC/sum(boc.sum.TgC)*100,1)]
boc.smry.dt

# forest soil carbon stocks -----------------------------
soc.smry.dt <- nf.dt[forest == 1 & fed == 1, .(soc.avg.MgCha = round(mean(soc.MgCha, na.rm=T)), 
                                    soc.sd.MgCha = round(sd(soc.MgCha, na.rm=T)),
                                    soc.sum.TgC = round(sum(soc.MgCpxl, na.rm=T)/10^6,1)), 
                     by = nf.name]
soc.smry.dt[, soc.avg.MgCha.rank := rank(-soc.avg.MgCha)]
soc.smry.dt[, soc.sum.TgC.rank := rank(-soc.sum.TgC)]
soc.smry.dt[, soc.sum.TgC.pcnt.all.nf := round(soc.sum.TgC/sum(soc.sum.TgC)*100,1)]
soc.smry.dt

# forest ecosystem carbon stocks -----------------------------
totc.smry.dt <- nf.dt[forest == 1 & fed == 1, .(totc.avg.MgCha = round(mean(totc.MgCha, na.rm=T)), 
                                     totc.sd.MgCha = round(sd(totc.MgCha, na.rm=T)),
                                     totc.sum.TgC = round(sum(totc.MgCpxl, na.rm=T)/10^6,1)), 
                      by = nf.name]
totc.smry.dt[, totc.avg.MgCha.rank := rank(-totc.avg.MgCha)]
totc.smry.dt[, totc.sum.TgC.rank := rank(-totc.sum.TgC)]
totc.smry.dt[, totc.sum.TgC.pcnt.all.nf := round(totc.sum.TgC/sum(totc.sum.TgC)*100,1)]
totc.smry.dt

# forest landscape integrity -----------------------------------
flii.smry.dt <- nf.dt[is.na(flii) == F & forest == 1 & fed == 1, .(flii.avg = round(mean(flii),1), 
                                          flii.sd = round(sd(flii),1), 
                                          flii.high.area.km2 = round(sum(flii.high)*(300*300)/10^6)), 
                      by = nf.name]
flii.smry.dt[, flii.avg.rank := rank(-flii.avg)]
flii.smry.dt[, flii.high.pcnt.all.nf := round(flii.high.area.km2/sum(flii.high.area.km2)*100,1)]

# forest burn area ---------------------------------------------
burn.smry.dt <- nf.dt[forest == 1 & fed == 1, .(forest.area.km2 = round(.N *(300*300)/10^6), burn.area.km2 = round(sum(burned)*(300*300)/10^6)), by = nf.name]
burn.smry.dt[, burn.area.pcnt := round(burn.area.km2/forest.area.km2*100,2)]
burn.smry.dt[, burn.area.pcnt.rank := rank(-burn.area.pcnt)]
burn.smry.dt[, burn.area.rank := rank(-burn.area.km2)]
burn.smry.dt[, burn.area.pcnt.all.nf := round(burn.area.km2 / sum(burn.area.km2)*100,2)]
burn.smry.dt <- burn.smry.dt[, forest.area.km2 := NULL]

# combine all summaries back together
nf.smry.dt <- nf.smry.dt[agc.smry.dt, on = 'nf.name']
nf.smry.dt <- nf.smry.dt[bgc.smry.dt, on = 'nf.name']
nf.smry.dt <- nf.smry.dt[boc.smry.dt, on = 'nf.name']
nf.smry.dt <- nf.smry.dt[soc.smry.dt, on = 'nf.name']
nf.smry.dt <- nf.smry.dt[totc.smry.dt, on = 'nf.name']
nf.smry.dt <- nf.smry.dt[flii.smry.dt, on = 'nf.name']
nf.smry.dt <- nf.smry.dt[burn.smry.dt, on = 'nf.name']
# nf.smry.dt <- nf.smry.dt[hist.clim.dt, on = 'nf.name']
setorder(nf.smry.dt, nf.name)
nf.smry.dt

fwrite(nf.smry.dt, file = 'output/natl_forest_condition_summary.csv')


# CREATE PRETTY VERSION OF SUMMARY TABLE TO INCLUDE IN SUPPLEMENTAL ============
nf.smry.dt <- fread('output/natl_forest_condition_summary.csv')
nf.smry.dt



# ==============================================================================
# SUMMARIZE CLIMATE DATA SEPARATELY ============================================
# ==============================================================================

# add forest flag to climate data
clim.dt$forest <- nf.dt$forest[match(clim.dt$cell.id, nf.dt$cell.id)]

# subset climate data to forest lands
clim.dt <- clim.dt[forest == 1]

# summarize historical climate for each national forest
clim.hist.dt <- clim.dt[period == '1981-2010']

clim.hist.smry.dt <- clim.hist.dt[, .(mean = mean(value), sd = sd(value)), by = c('nf.name','variable')]
clim.hist.smry.dt <- dcast(clim.hist.smry.dt, nf.name ~ variable, value.var = c('mean','sd'))
colnames(clim.hist.smry.dt) <- c('nf.name','ppt.avg','tmax.avg','ppt.sd','tmax.sd')

fwrite(clim.hist.smry.dt, file = 'output/natl_forest_historical_climate_summaries.csv')


# summarize future climate for each national forest
clim.fut.dt <-  clim.dt[period != '1981-2010']
setnames(clim.fut.dt, 'value','fut.value')
clim.fut.dt[variable == 'bio12', hist.value := rep(clim.hist.dt[variable == 'bio12']$value, 5)]
clim.fut.dt[variable == 'bio5', hist.value := rep(clim.hist.dt[variable == 'bio5']$value, 5)]
clim.fut.dt[, change := fut.value - hist.value]

clim.fut.smry.dt <- clim.fut.dt[, .(fut.value = mean(fut.value), 
                                    change = mean(change)), 
                                by = c('nf.name','variable','esm')]

clim.fut.smry.dt <- clim.fut.smry.dt[, .(fut.value.med = median(fut.value),
                                         fut.value.min = min(fut.value),
                                         fut.value.max = max(fut.value),
                                         change.med = median(change),
                                         change.min = min(change),
                                         change.max = max(change)), by = c('nf.name','variable')]

clim.fut.smry.dt <- dcast(clim.fut.smry.dt, nf.name ~ variable, value.var = colnames(clim.fut.smry.dt)[-c(1,2)])

clim.fut.smry.dt[, ':='(change.med_bio5.rank = rank(-change.med_bio5),
                        change.med_bio12.rank = rank(-change.med_bio12))]


fwrite(clim.fut.smry.dt, file = 'output/natl_forest_climate_summaries.csv')


# END SCRIPT ===================================================================


# climate vs burned area 
plot(log10(nf.smry.dt$ppt.avg), nf.smry.dt$burn.area.pcnt)
plot(nf.smry.dt$tmax.avg, nf.smry.dt$burn.area.pcnt)
summary(lm(burn.area.pcnt ~ tmax.avg + log10(ppt.avg), nf.smry.dt))

# climate vs carbon stocks
plot(nf.smry.dt$tmax.avg, nf.smry.dt$agc.avg.MgCha)
plot(log10(nf.smry.dt$ppt.avg), nf.smry.dt$agc.avg.MgCha)
plot(nf.smry.dt$ppt.avg, nf.smry.dt$agc.avg.MgCha)
summary(lm(agc.avg.MgCha ~ tmax.avg + log10(ppt.avg), nf.smry.dt))

plot(nf.smry.dt$ppt.avg, nf.smry.dt$totc.avg.MgCha)
plot(log10(nf.smry.dt$ppt.avg), nf.smry.dt$totc.avg.MgCha)

cor.test(log10(nf.smry.dt$ppt.avg), nf.smry.dt$agc.avg.MgCha)
cor.test(nf.smry.dt$ppt.avg, nf.smry.dt$agc.avg.MgCha)


# EXAMINE C STOCKS ACROSS FOREST + NON FOREST LANDS ============================

# forest aboveground carbon stocks -----------------------------
agc.smry.dt <- nf.dt[gap.sts > 1, .(agc.avg.MgCha = round(mean(agc.MgCha, na.rm=T)), 
                                    agc.sd.MgCha = round(sd(agc.MgCha, na.rm=T)),
                                    agc.sum.TgC = round(sum(agc.MgCpxl, na.rm=T)/10^6,1)), 
                     by = nf.name]

agc.smry.dt[nf.name == 'Tongass National Forest' | nf.name == 'Chugach National Forest']


