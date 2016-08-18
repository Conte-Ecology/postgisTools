#!/bin/bash
# Updates the database in preparation for running the zonal statistics tools. 

# usage: $ ./update_database.sh <db name> 
# example: $ ./update_database.sh sheds

set -eu
set -o pipefail

# User inputs
DB=$1



psql -d $DB -c"

  -- Fix catchments geometry
  UPDATE gis.catchments 
    SET geom = ST_MakeValid(geom);

  -- Add new schema for raster layers
  CREATE SCHEMA rasters;

  -- Update search path (super user)
  ALTER DATABASE sheds_new SET search_path TO public, gis, data, rasters;

  -- Update search path (regular user)
  -- ALTER ROLE kyle SET search_path to public, gis, data, rasters;

  -- Add centroids geometry
  ALTER TABLE gis.catchments
    ADD COLUMN centroids geometry(Geometry, 4326);
  
  UPDATE gis.catchments 
    SET centroids = ST_Centroid(geom);

  CREATE INDEX catchments_centroids_gist ON gis.catchments USING gist(centroids);"