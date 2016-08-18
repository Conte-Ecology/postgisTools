
-- Prep 







#!/bin/bash
# imports covariates to existing db table 'data.covariates'
# csv file must have columns [featureid, variable, value, zone]

# usage: $ ./append_covariates.sh <db name> <path to covariates directory>
# example: $ ./zonal_stats.sh sheds_new catchments ann_tmin_c
set -eu
set -o pipefail

DB=$1
ZONES=$2
RASTER=$3

RASTER_TABLE=$RASTER"_stats"

# Perform zonal statistics on raw, but projected raster
psql -d zstats -c"
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









U


UPDATE rasters.tmax_prj 
  SET rast_4326 = ST_Transform(rast, 4326)
  FROM spatial_ref_sys;

SELECT ST_Transform(rast, 4326) INTO tmax_prj_wgs
FROM tmax_prj;



SELECT * 
FROM spatial_ref_sys
WHERE srid = 5070;







-- User will need to need to find srid of 

raster2pgsql -I -C -M -t 500x500 tmax_prj rasters.tmax_prj2| psql -d zstats 



SELECT ST_SRID(rast)
FROM tmax_prj;