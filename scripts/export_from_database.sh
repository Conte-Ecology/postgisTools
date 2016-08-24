# EXPORT FROM DATABASE
# ====================
 
# Table
# ----- 
psql -d sheds_new -c"COPY stats_elevation TO STDOUT WITH CSV HEADER" > /home/kyle/postgis_tools/zonal_statistics/tables/stats_elevation.csv


# Raster
# ------
# Outputs to the current directory

#GTIFF
gdal_translate -of GTiff -outsize 100% 100% "PG:host=localhost port=5432 dbname='sheds_new' user='kyle' schema='rasters' table=tmax_raw" tmax_raw.tif

#PNG
gdal_translate -of PNG -outsize 100% 100% "PG:host=localhost port=5432 dbname='zstats' user='kyle' schema='rasters' table=tmax_prj" tmax_prj.png


# Shapefile
# ---------
pgsql2shp -f cats sheds_new "select featureid, geom from cats"

pgsql2shp -f outputname -h localhost -u user -P password gisdb "SELECT * FROM table"
