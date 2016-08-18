rm(list = ls())

library(foreign)
library(dplyr)

tables <- "C:/KPONEIL/postgisTools/zonalStatistics/tables"





layerName <- "ann_tmin_c"



# Compare Postgres and ArcGIS methods
# -----------------------------------
psql <- read.csv(file.path(tables, "psql_stats.csv"))

names(psql) <- c("featureid", "p_count", "p_mean")


arc <- read.dbf(file.path(tables, "arc_stats.dbf"), as.is = T)

arc$feat <- as.integer(arc$feat)

names(arc) <- c("featureid", "ZONE_CODE", "a_count", "AREA", "a_mean")

arc$featureid <- as.numeric(arc$featureid)



join <- left_join(psql, arc, by = "featureid") %>%
  mutate( mean_diff = p_mean - a_mean) %>%
  mutate( count_diff = p_count - a_count)

range(join$mean_diff)
range(join$count_diff)






# Compare methods within Postgres
# -------------------------------

abbrev <- "tmax"

cats <- read.dbf("C:/KPONEIL/postgisTools/zonalStatistics/spatial/shapefiles/largeCats.dbf")
cats <- cats[,c("FEATUREID", "NextDownID", "AreaSqKM")]
names(cats)[1] <- "featureid"




prj <- read.csv(file.path(tables, paste0("sum_", abbrev, "_prj.csv")))
names(prj) <- c("featureid", "prj_pix", "prj_mean")
raw <- read.csv(file.path(tables, paste0("sum_", abbrev, "_raw.csv")))
names(raw) <- c("featureid", "raw_pix", "raw_mean")
res <- read.csv(file.path(tables, paste0("sum_", abbrev, "_res.csv")))
names(res) <- c("featureid", "res_pix", "res_mean")

arc <- read.dbf(file.path(tables, "largeCats_tmax_stats.dbf"), as.is = T)
arc$feat <- as.integer(arc$feat)
names(arc) <- c("featureid", "ZONE_CODE", "arc_pix", "AREA", "arc_mean")
arc$featureid <- as.numeric(arc$featureid)

arc <- arc[,c("featureid", "arc_pix", "arc_mean")]

join1 <- left_join(cats, prj, by = "featureid")
join2 <- left_join(join1, raw, by = "featureid")
join3 <- left_join(join2, res, by = "featureid")
join4 <- left_join(join3, arc, by = "featureid")


join4$diff1 <- join4$prj_mean - join4$raw_mean
join4$diff2 <- join4$prj_mean - join4$res_mean
join4$diff3 <- join4$prj_mean - join4$arc_mean



means <- join4[,c("featureid", "NextDownID", "AreaSqKM", "prj_mean", "raw_mean", "res_mean", "arc_mean")]


sqrt( mean( (join4$prj_mean-join4$res_mean)^2 , na.rm = TRUE ) )

# Export for Arc
outMeans <- means
means[is.na(means)] <- -9999

write.dbf(means, file.path(tables, "means.dbf"))


range(join4$diff1, na.rm = T)
range(join4$diff2, na.rm = T)
range(join4$diff3, na.rm = T)

join4[which(join4$diff2 > .2),]
