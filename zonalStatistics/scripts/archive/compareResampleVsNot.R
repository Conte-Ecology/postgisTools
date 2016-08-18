library(foreign)
library(dplyr)

# PSQL
# ----
psql <- read.csv("C:/KPONEIL/postgisTools/zonalStatistics/tables/sum_tmin2.csv")

names(psql)[3] <- 'psql'


# ARC
# ---

table <- "C:/KPONEIL/SHEDS/basinCharacteristics/zonalStatistics/versions/NHDHRDV2/gisTables/Catchments"

regions <- c("01", "02", "03", "04", "05", "06")

for (i in seq_along(regions)){
  stats <- read.dbf(paste0(table, regions[i], "/ann_tmin_c.dbf"))

  if(!exists("allStats")){
    allStats <- stats
  } else( allStats <- rbind(allStats, stats))
}


# Compare
# -------

arc <- allStats[,c("FEATUREID", "MEAN")]
names(arc) <- c("featureid", "arc")


join <- left_join(psql, arc, by = "featureid")


sqrt( mean( (join$arc-join$psql)^2 , na.rm = TRUE ) )



# Also separately compare the catchments that were sampled from the centroid vs 
#   those that had a successful intersection with raster cells (normal zonal stats)


