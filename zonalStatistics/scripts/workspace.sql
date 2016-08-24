
./query_daymet.sh sheds_new /home/kyle/postgis_tools/query_daymet/input/AGB_Sites.csv /home/kyle/workspace/testRecord.csv '2010-01-01' '2010-01-31'







SELECT * INTO gis.cats
FROM catchments
WHERE featureid in (201480095, 201480170, 201480094, 201481180, 201480985, 201480965, 201480850);






-- Self-intersection issue


SELECT * INTO gis.cats
FROM catchments
WHERE featureid in (2021034683, 2021035323, 2021034779, 2021034780, 2021035324);

select ST_IsValid(geom)
from catchments;

UPDATE gis.catchments 
  SET geom = ST_MakeValid(geom);

select ST_IsValid(geom)
from cats;
  
  
$ pgsql2shp -f qds_cnt -h localhost -u postgres -P password gisdb "SELECT sp_count, geom FROM grid50_rsa WHERE province = 'Gauteng'"
  
  

time /home/kyle/scripts/db/gis/covariate_rasters/import_covariate_rasters.sh sheds_new /home/kyle/data/gis/covariates/rasters/outputFiles/elevation

time /home/kyle/scripts/postgis_tools/zonal_statistics.sh sheds_new catchments elevation

/home/kyle/scripts/postgis_tools/zonal_statistics.sh sheds_new cats elevation

psql -d sheds -c"COPY raster_types TO STDOUT WITH CSV HEADER" > /home/kyle/postgisTools/zonalStatistics/tables/stats_forest.csv




SELECT *
FROM st_gdaldrivers()
ORDER BY short_name;
psql -d sheds -c"COPY raster_types TO STDOUT WITH CSV HEADER" > /home/kyle/workspace/raster_types.csv







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

