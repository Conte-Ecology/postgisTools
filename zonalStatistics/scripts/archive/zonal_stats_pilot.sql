-- Working script based on documentation of ST_SummaryStats function
-- Needs to be compared with arcgis version of stats

WITH sum_stats AS (
-- clip band 2 of raster tiles to boundaries of builds
-- then get stats for these clipped regions
  SELECT  featureid, (stats).*
  FROM (
	SELECT featureid, ST_SummaryStats(ST_Clip(rast,geom)) AS stats
    FROM rasters.tmax_raw
      INNER JOIN cats_large ON ST_Intersects(cats_large.geom,rast) 
  ) AS pod
)
-- finally summarize stats
SELECT 
  featureid, 
  SUM(count) AS num_pixels,
  SUM(mean*count)/SUM(count) AS mean
INTO sum_tmax_raw
FROM sum_stats
 WHERE count > 0
  GROUP BY featureid
  ORDER BY featureid;

  
WITH sum_stats AS (
-- clip band 2 of raster tiles to boundaries of builds
-- then get stats for these clipped regions
  SELECT  featureid, (stats).*
  FROM (
	SELECT featureid, ST_SummaryStats(ST_Clip(rast,geom)) AS stats
    FROM rasters.tmax_res
      INNER JOIN cats_large ON ST_Intersects(cats_large.geom,rast) 
  ) AS pod
)
-- finally summarize stats
SELECT 
  featureid, 
  SUM(count) AS num_pixels,
  SUM(mean*count)/SUM(count) AS mean
INTO sum_tmax_res
FROM sum_stats
 WHERE count > 0
  GROUP BY featureid
  ORDER BY featureid;  

WITH sum_stats AS (
-- clip band 2 of raster tiles to boundaries of builds
-- then get stats for these clipped regions
  SELECT  featureid, (stats).*
  FROM (
	SELECT featureid, ST_SummaryStats(ST_Clip(rast,geom)) AS stats
    FROM rasters.tmax_prj
      INNER JOIN cats_large ON ST_Intersects(cats_large.geom,rast) 
  ) AS pod
)
-- finally summarize stats
SELECT 
  featureid, 
  SUM(count) AS num_pixels,
  SUM(mean*count)/SUM(count) AS mean
INTO sum_tmax_prj
FROM sum_stats
 WHERE count > 0
  GROUP BY featureid
  ORDER BY featureid;  


