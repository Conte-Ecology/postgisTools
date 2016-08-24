Zonal Statistics
================


# Description
This repository contains the scripts used to generate the catchment attributes 
for value rasters provided through the Postgres database. The tools make use 
of the existing database structure in the sheds database and the hydrography 
layers from the [NHDHRDV2](http://conte-ecology.github.io/shedsGisData/) are 
utilized. The process is an adaptation of the existing work in the
[basinCharacteristics](https://github.com/Conte-Ecology/shedsGisData/tree/master/basinCharacteristics) 
repo which refers to the same process performed in ArcGIS. The Comparison 
Metrics attempts to quantify the differences between the two methods.
<br><br>


# Workflow

## Update database

### Description
A few minor updates to the database are required to set it up to handle the 
raster processing in this section. A script is written to perform these updates 
on the database specified. The script should only be run once on a database.
The script will do the following:

1. Fix overlapping polygons in the `catchments` table
2. Add a geometry column for the polygon centroids to the `catchments` table
3. Create a new `rasters` schema for the raster tables and add it to the search 
path

### Execution
Execute the `update_database.sh` script in the bash. The only argument taken is 
the name of the database.

Example: `./update_database.sh sheds`

### Output
A new `rasters` schema is added to the database. A new column is added to the 
`catchments` table with the geometry of the polygon centroid.
<br><br>

## Upload Raster

### Description
The script uploads the raster from it's location on the server to the specified 
database. Upload time can range from a few minutes up to an hour depending on 
pixel size and extent of the raster. Rasters with resolutions finer than 30x30m
and/or ranges exceeding that of the NHDHRDV2 may take even longer to upload.

### Execution
Execute the `import_covariate_rasters.sh` script in the bash. It takes 
arguments specifying the database and the full path to the raster for upload, 
in that order. The file extension of the raster should be included in the file 
path. The default tile size is 500x500 pixels, but may be changed by setting 
the tile size paramater of the `raster2pgsql` executable within the shell 
script. 

Example: `./import_covariate_rasters.sh sheds /home/data/rasters/ann_tmin_c.tif`

### Output
A new table representing the spatial information of the raster is created in the 
specified database. The table name is the same as the name of the raster layer 
being uploaded.
<br><br>

## Calculate Statistics

### Description
The average raster value within each of the zones is calculated based on the 
raster cells that have their centers inside of the polygon. If no pixel center 
falls inside the polygon then the value of the raster pixel that intersects the 
polygon centroid is assigned to that zone. This scenario is more likely to be 
the case with larger pixel size rasters. If neither of these conditions are 
met, the zone receives no value and is omitted from the output table. The 
entire process currently takes 3-4 hours for the entire NHDHRDV2 range with 
a raster of matching extent.

### Execution
Execute the `zonal_statistics.sh` script in the bash. In order, the arguments 
are the database name, the name of the table defining the zones, and the name 
of the table of the value raster (uploaded in the previous section). 

Example: `./zonal_statistics.sh sheds catchments ann_tmin_c`

The resulting database table can then be output to a CSV file using "COPY" 
and specifying the output location.

Example: `psql -d sheds -c"COPY stats_forest TO STDOUT WITH CSV HEADER" > /home/data/tables/stats_forest.csv`

### Output
A table is output to the database with 3 columns identifying the zone, the 
number of raster pixels involved in the calulation, and the mean value of the 
raster in that zone. The mean value units match that of the raster layer. Table 
1 shows an example output table.

| featureid | num_pixels | mean  |
| :-------: | :--------: | :---: |
| 20625492  |    3       | 5.663 |
| 20625493  |    2       | 5.660 |
| 20625494  |    6       | 5.380 |
| 20625495  |    5       | 5.474 |
| 20625496  |    2       | 5.635 |
Table 1: Example output table
<br><br>


# Raster Requirements & Recommendations
The catchment layer used for the zones in this process is based on a 30x30 meter 
grid cell resolution. Rasters with a finer resolution than this can be resampled 
with the goal of saving space as well as upload and process time. The current 
allowable raster types for upload are listed in Table 2.


| Short Name | Long Name |
| ---------- | --------- |
|	AAIGrid	|	Arc/Info ASCII Grid	|
|	ARG	|	Azavea Raster Grid format	|
|	DTED	|	DTED Elevation Raster	|
|	EHdr	|	ESRI .hdr Labelled	|
|	FIT	|	FIT Image	|
|	GIF	|	Graphics Interchange Format (.gif)	|
|	GS7BG	|	Golden Software 7 Binary Grid (.grd)	|
|	GSAG	|	Golden Software ASCII Grid (.grd)	|
|	GSBG	|	Golden Software Binary Grid (.grd)	|
|	GTiff	|	GeoTIFF	|
|	HF2	|	HF2/HFZ heightfield raster	|
|	HFA	|	Erdas Imagine Images (.img)	|
|	ILWIS	|	ILWIS Raster Map	|
|	INGR	|	Intergraph Raster	|
|	JPEG	|	JPEG JFIF	|
|	KMLSUPEROVERLAY	|	Kml Super Overlay	|
|	LCP	|	FARSITE v.4 Landscape File (.lcp)	|
|	NITF	|	National Imagery Transmission Format	|
|	PNG	|	Portable Network Graphics	|
|	R	|	R Object Data Store	|
|	RST	|	Idrisi Raster A.1	|
|	SAGA	|	SAGA GIS Binary Grid (.sdat)	|
|	SRTMHGT	|	SRTMHGT File Format	|
|	USGSDEM	|	USGS Optional ASCII DEM (and CDED)	|
|	VRT	|	Virtual Raster	|
|	XPM	|	X11 PixMap Format	|
|	XYZ	|	ASCII Gridded XYZ	|
|	ZMap	|	ZMap Plus Grid	|
Table 2: Allowable raster types
<br><br>


# Comparison Metrics
The comparison metrics table provides a comparison of the Postgres method for 
calculating zonal statistics to the baseline of the ArcGIS method, which 
resamples rasters prior to running the zonal statistics tool. Four sample 
rasters are shown to compare how the method varies over data types and 
spatial resolution. The root-mean-square error is calculated for all of the 
records with the ArcGIS values being considered the baseline. RMSEs are also 
calculated separately for the two methods used in the Postgres scripts, with 
"point" referring to the centroid method and "areal"" refering to the spatial 
average. The catchment loss count refers to the number of catchments with NA 
values in the Postgres method that have values with the ArcGIS method. The 
final columns show the range of raster values for each of the methods for 
reference. In general, the Postgres method seems to be acceptable in its 
difference from the ArcGIS method. The method does show an increasing loss of 
catchments as raster resolution increases, but this could be solved by 
resampling rasters prior to upload.

| Layer Name   | Spatial Resolution | RMSE  | Point RMSE | Areal RMSE | Catchment Loss Count | Arc Min Value | Arc Max Value | PSQL Min Value | PSQL Max Value |
| :--------:   | :----------------: | ----  | ---------- | ---------- | -------------------- | ------------- | ------------- | -------------- | -------------- |
| forest       | 30 x 30 meters     | 0.019 | 0.265      | 0.018      | 0                    | 0.000         | 1.000         | 0.000          | 1.000          |
| elevation    | 30 x 30 meters     | 0.221 | 0.557      | 0.220      | 0                    | -0.167        | 1512.304      | -0.186         | 1512.278       |
| ann_tmin_c   | 800 x 8000 meters  | 0.077 | 0.071      | 0.078      | 168                  | -4.197        | 13.208        | -4.465         | 13.260         |
| dep_so4_2011 | ~ 2.3 x 2.3 km     | 0.141 | 0.146      | 0.123      | 2692                 | 4.958         | 24.982        | 4.952          | 25.037         |
Table 3: Metrics comparing the Postgres method to the baseline of the ArcGIS method.
<br><br>


# Contact Info
Kyle O'Neil  
koneil@usgs.gov  
