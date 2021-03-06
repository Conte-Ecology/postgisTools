rm(list=ls())

library(foreign)
library(dplyr)


# Prep work
layerNames <- c("forest", "elevation", "ann_tmin_c", "dep_so4_2011")


psqlTables <- "C:/KPONEIL/postgisTools/zonalStatistics/tables"

arcTables <- "C:/KPONEIL/SHEDS/basinCharacteristics/zonalStatistics/versions/NHDHRDV2/gisTables"

metrics <- as.data.frame(matrix(nrow = length(layerNames), ncol = 5))
names(metrics) <- c("Layer_Name", "RMSE", "Point_RMSE", "Areal_RMSE", "Catchment_Loss_Count")



for (j in seq_along(layerNames)){

  # PSQL Stats
  # ----------
  psqlStats <- read.csv(file.path(psqlTables, paste0("stats_", layerNames[j], ".csv")))
  
  names(psqlStats) <- c("FEATUREID", "psql_count", "psql")
  
  
  # Arc Stats
  # ---------
  regions <- c("01", "02", "03", "04", "05", "06")
  
  for (i in seq_along(regions)){
    
    stats <- read.dbf(paste0(arcTables, "/Catchments", regions[i], "/", layerNames[j], ".dbf"))[,c("FEATUREID", "COUNT", "MEAN")]
    
    if(!exists("arcStats")){
      arcStats <- stats
    } else {
      arcStats <- rbind(arcStats, stats)
    }
  }
  
  names(arcStats) <- c("FEATUREID", "arc_count", "arc")
  
  arcStats$arc[which(arcStats$arc == -9999)] <- NA

  
  # Calculate Stats
  # ---------------

  allStats <- left_join(psqlStats, arcStats, by = "FEATUREID")
  
  # Missing values
  missingArc <- which(is.na(allStats$arc))
  missingPSQL <- which(is.na(allStats$psql))
  both <- which(is.na(allStats$arc) & is.na(allStats$psql))

  # Stat assignment method (average vs point sample)
  point <- allStats[which(is.na(allStats$psql_count)),]
  areal <- allStats[which(!is.na(allStats$psql_count)),]

  # Layer name
  metrics$Layer_Name[j] <- layerNames[j]
  
  # Min/max values
  metrics$Arc_Min_Value[j]  <- round(min(allStats$arc,  na.rm = T), digits = 3)
  metrics$Arc_Max_Value[j]  <- round(max(allStats$arc,  na.rm = T), digits = 3)
  metrics$PSQL_Min_Value[j] <- round(min(allStats$psql, na.rm = T), digits = 3)
  metrics$PSQL_Max_Value[j] <- round(max(allStats$psql, na.rm = T), digits = 3)
  
  # RMSE 
  metrics$RMSE[j] <- round(sqrt(mean((allStats$arc-allStats$psql)^2 , 
                                     na.rm = TRUE ) ), 
                           digits = 3)
  
  # Extra catchments missing PSQL
  metrics$Catchment_Loss_Count[j] <- length(missingPSQL) - length(both)
 
  # Point RMSE 
  metrics$Point_RMSE[j] <- round(sqrt(mean((point$arc-point$psql)^2 , 
                                            na.rm = TRUE ) ), 
                                 digits = 3)
  
  # Areal RMSE 
  metrics$Areal_RMSE[j] <- round(sqrt(mean((areal$arc-areal$psql)^2 , 
                                           na.rm = TRUE ) ), 
                                 digits = 3)

  # Remove variables
  rm(arcStats)
}

print(metrics)
