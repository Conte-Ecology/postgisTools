
SELECT * INTO gis.cats
FROM catchments
WHERE featureid in (201480095, 201480170, 201480094, 201481180, 201480985, 201480965, 201480850);


ALTER TABLE gis.catchments
  ADD COLUMN centroids geometry(Geometry, 4326); 
  
UPDATE gis.catchments 
  SET centroids = ST_Centroid(geom);

CREATE INDEX catchments_centroids_gist ON gis.catchments USING gist(centroids); 



/home/kyle/scripts/db/gis/covariate_rasters/import_covariate_rasters.sh sheds_new dep_so4_2011 /home/kyle/data/gis/covariates/rasters

/home/kyle/scripts/postgis_tools/zonal_statistics.sh sheds_new catchments dep_so4_2011

psql -d sheds_new -c"COPY stats_dep_so4_2011 TO STDOUT WITH CSV HEADER" > /home/kyle/postgisTools/zonalStatistics/tables/stats_dep_so4_2011.csv





SELECT (md).*, (bmd).*
FROM (SELECT ST_Metadata(rast) AS md, 
              ST_BandMetadata(rast) AS bmd 
       FROM tmax_raw LIMIT 1
      ) foo;





-- First resample the raster to match the catchment raster
-- ***** MAKE METHOD USER SPECIFIED (BASED ON RASTER TYPE) ******
select 
  ST_Resample(rasters.tmax_raw.rast, rasters.tmax_prj.rast, 'Cubic') as rast
into rasters.tmax_res
from tmax_raw, tmax_prj;


-- Get raster attributes
-- =====================

-- Get pixel size
SELECT ST_PixelWidth(rast)
FROM tmax_prj;

-- Get scale X and Y
SELECT ST_ScaleX(rast)
FROM tmax_prj;

SELECT ST_ScaleY(rast)
FROM tmax_prj;

-- Get raster width + height
SELECT ST_Width(rast)
FROM catchments;

SELECT ST_Height(rast)
FROM tmax_prj;


-- Get raster skew
SELECT ST_SkewX(rast)
FROM tmax_prj;

SELECT ST_SkewY(rast)
FROM tmax_prj;

-- Upper left (reference) coordinates
SELECT ST_UpperLeftX(rast)
FROM tmin;

SELECT ST_UpperLeftY(rast)
FROM tmax_prj;

-- Tiled Raster
SELECT MIN(ST_UpperLeftX(rast))
FROM catchments_raster;

SELECT MAX(ST_UpperLeftY(rast))
FROM tmax_prj;


-- ST_BandNoDataValue - set the nodata value
-- ST_Rescale - resize the raster cells

