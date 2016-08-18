
-- Methods:
-- ========
-- Nearest Neighbor - categorical data (e.g. land-use) where the cell will keep the same value
-- Bilinear - continuous data (e.g. elevation, climate) where cell value might be different, but will be within range of inputs
--     Averages values @ 4 nearest cell centers. 
-- Cubic - continuous data (e.g. elevation, climate) where cell value might be outside range of values
--     Fits a smoooth curve through the 16 nearest cell centers.


-- Options will be Nearest Neighbor or Cubic based on raster type (continuous or categorical)

ID
TYPE


-- Resample the value raster to match the zonal raster
EXPLAIN SELECT 
  ST_Resample(rasters.forest.rast, gis.catchments_raster.rast, 'Cubic') AS rast
INTO rasters.forest_res
FROM rasters.forest, gis.catchments_raster;


-- Perform zonal statistics
EXPLAIN WITH sum_stats AS (
  SELECT  featureid, (stats).*
  FROM (
	SELECT featureid, ST_SummaryStats(ST_Clip(rast,geom)) AS stats
    FROM rasters.tmin
      INNER JOIN cats_large ON ST_Intersects(cats_large.geom,rast) 
  ) AS pod
)
SELECT 
  featureid, 
  SUM(count) AS num_pixels,
  SUM(mean*count)/SUM(count) AS mean
INTO sum_tmin
FROM sum_stats
 WHERE count > 0
  GROUP BY featureid
  ORDER BY featureid;
  
  
