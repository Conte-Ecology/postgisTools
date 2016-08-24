#!/bin/bash
# imports gage sites with lat/lon, pairs with FEATUREID, and exports daily daymet record for all 7 daymet variables
# Imported CSV file must have 3 columns: site_no, long, lat
# In leap years, December 31st is truncated from the record

# usage: $ ./query_daymet.sh <db name> <path to sites CSV file> <output CSV file path> <start date> <end date>
# example: $ ./query_daymet.sh sheds_new /home/kyle/postgis_tools/query_daymet/input/NEWAGBSites86.csv /home/kyle/postgis_tools/query_daymet/output/NEWAGBSites86.csv 1982-01-01 2010-12-31


set -eu
set -o pipefail

DB=$1
SITES=$2
RECORD=$3
STARTDATE=$4
ENDDATE=$5

# Create the table of manually edited huc12 assignemnts + update permissions
psql -d $DB -c  "CREATE TABLE gage_sites (
					site_no varchar(20),
					long  numeric,
					lat  numeric
                );"

psql -d $DB -c  "\COPY gage_sites FROM $SITES DELIMITER ',' CSV HEADER NULL AS 'NA';"

psql -d $DB -c  "ALTER TABLE gage_sites ADD COLUMN geom geometry(POINT,4269);
                 UPDATE gage_sites SET geom = ST_SetSRID(ST_MakePoint(long, lat),4269);
                 CREATE INDEX idx_gage_sites_geom_gist ON gage_sites USING GIST(geom);

                 ALTER TABLE gage_sites
                   ADD COLUMN geom_4326 geometry(Geometry,4326);
  
                 UPDATE gage_sites 
                   SET geom_4326 = ST_Transform(geom, 4326)
                   FROM spatial_ref_sys 
                   WHERE ST_SRID(geom) = srid;
  
                 CREATE INDEX idx_gage_sites_geom_4326_gist ON gage_sites USING gist(geom_4326);

                 SELECT site_no, long, lat, featureid INTO TEMPORARY intersections
                   FROM gage_sites AS gs
                   INNER JOIN gis.catchments AS c
                   ON ST_Intersects(gs.geom_4326, c.geom);
				   
                 WITH d AS (
                   SELECT * 
                   FROM get_daymet_featureids_date_range_bigint((SELECT array_agg(featureid) FROM intersections), '$STARTDATE', '$ENDDATE')
                 )
                 SELECT i.site_no, d.featureid, d.date, d.tmax, d.tmin, d.prcp, d.dayl, d.srad, d.vp, d.swe INTO final_record
                   FROM intersections i
                   LEFT JOIN d 
                   ON d.featureid=i.featureid;"
                
psql -d $DB -c  "\COPY final_record TO $RECORD WITH CSV HEADER;"

psql -d $DB -c "DROP TABLE final_record;
                DROP TABLE gage_sites;"