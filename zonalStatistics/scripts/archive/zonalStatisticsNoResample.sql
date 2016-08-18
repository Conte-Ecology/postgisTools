
ID
TYPE

CREATE INDEX cats_geom_gist ON gis.cats USING gist(geom);  

-- Update Database
-- ===============

-- Add centroids to catchments 
ALTER TABLE gis.catchments
  ADD COLUMN centroids geometry(Geometry, 4326); 
  
UPDATE gis.catchments 
  SET centroids = ST_Centroid(geom);

CREATE INDEX catchments_centroids_gist ON gis.catchments USING gist(centroids);  


-- Create a new schema
CREATE SCHEMA rasters



UPDATE temp.hu12 
  SET geom_2163 = ST_Transform(geom, 2163)
  FROM spatial_ref_sys 

SELECT ST_SRID(geom) 
FROM gis.catchments;





-- Perform zonal statistics on raw, but projected raster
WITH sum_stats AS (
  SELECT  featureid, (stats).*
  FROM (
	SELECT featureid, ST_SummaryStats(ST_Clip(rast,geom)) AS stats
    FROM rasters.tmin2
      INNER JOIN catchments ON ST_Intersects(catchments.geom,rast) 
  ) AS pod
)
SELECT 
  featureid, 
  SUM(count) AS num_pixels,
  SUM(mean*count)/SUM(count) AS mean
INTO sum_tmin2
FROM sum_stats
 WHERE count > 0
  GROUP BY featureid
  ORDER BY featureid;
  
-- select zones that did not get assigned 

INSERT INTO sum_tmin2(featureid, mean) (
  WITH missing_cats AS (
    SELECT c.*
    FROM 
      catchments c 
      LEFT JOIN sum_tmin2 s ON c.featureid=s.featureid
    WHERE s.mean IS NULL
  )
  SELECT featureid, ST_Value(rast, centroids) as mean
  FROM tmin2, missing_cats
  WHERE ST_Intersects(rast, centroids)
);






select * 
from test 
where st_value is not null;



