#!/bin/bash
# Runs zonal statistics for the specified zones and value layers. 

# usage: $ ./zonal_statistics.sh <db name> <zones table name> <raster name>
# example: $ ./zonal_statistics.sh sheds_new catchments ann_tmin_c

set -eu
set -o pipefail

# User inputs
DB=$1
ZONES=$2
RASTER=$3

# Output table
RASTER_TABLE="stats_"$RASTER

# Perform zonal statistics on raw, but projected raster
psql -d $DB -c"
  WITH sum_stats AS (
    SELECT  featureid, (stats).*
    FROM (
    SELECT featureid, ST_SummaryStats(ST_Clip(rast,geom)) AS stats
    FROM rasters.$RASTER
      INNER JOIN $ZONES ON ST_Intersects($ZONES.geom,rast) 
    ) AS pod
  )
  SELECT 
    featureid, 
    SUM(count) AS num_pixels,
    SUM(mean*count)/SUM(count) AS mean
  INTO data.$RASTER_TABLE
  FROM sum_stats
   WHERE count > 0
    GROUP BY featureid
    ORDER BY featureid;
    
  INSERT INTO data.$RASTER_TABLE(featureid, mean) (
    WITH missing_cats AS (
    SELECT c.*
    FROM 
      $ZONES c 
      LEFT JOIN data.$RASTER_TABLE s ON c.featureid=s.featureid
    WHERE s.mean IS NULL
    )
    SELECT featureid, ST_Value(rast, centroids) as mean
    FROM rasters.$RASTER, missing_cats
    WHERE ST_Intersects(rast, centroids)
  );"
