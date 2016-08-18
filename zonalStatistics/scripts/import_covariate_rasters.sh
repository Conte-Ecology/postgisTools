#!/bin/bash
# Imports covariate rasters in the ESRI Grid form 
# Converts TIFF format and transforms into WGS84 before upload

# usage: $ ./import_covariate_rasters.sh <db name> <full path to raster layer>
# example: $ ./import_covariate_rasters.sh sheds_new /home/kyle/data/gis/covariates/rasters/ann_tmin_c.tif

set -eu
set -o pipefail

# Input variables
# ---------------
# User inputs
DB=$1
RASTER_PATH=$2


# Strings
# -------
# Layer name
RASTER=${RASTER_PATH##*/}

# Directory
DIRECTORY=${RASTER_PATH%/*}

# Drop ext for raster name
RASTER_NAME=${RASTER%.*}

# Transformed raster
RASTER_WGS=$RASTER_NAME"_wgs84.tif"

# Processing
# ----------
# Create schema for rasters
psql -d $DB -c"CREATE SCHEMA IF NOT EXISTS rasters;"

# Transform + reformat raster
echo Transforming raster for upload...
gdalwarp -t_srs EPSG:4326 $RASTER_PATH $DIRECTORY"/"$RASTER_WGS

# Upload raster to the database
echo Uploading raster to database...
raster2pgsql -s 4326 -I -C -M -t 500x500 $DIRECTORY"/"$RASTER_WGS rasters.$RASTER_NAME| psql -d $DB
