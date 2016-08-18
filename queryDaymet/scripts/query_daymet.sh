#!/bin/bash
# imports gage sites with lat/lon, pairs with FEATUREID, and exports daily daymet record for tmin, tmax, and prcp
# Imported CSV file must have 3 columns: site_no, long, lat

# usage: $ ./query_daymet.sh <db name> <path to sites CSV file> <path to output csv> <start year> <end year>
# example: $ ./query_daymet.sh sheds_new /home/kyle/workspace/AGBSites.csv /home/kyle/workspace/daymetRecord.csv 1994 2010


set -eu
set -o pipefail

DB=$1
SITES=$2
RECORD=$3
STARTYEAR=$4
ENDYEAR=$5

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

                 SELECT i.site_no, d.featureid, d.date, d.tmax, d.tmin, d.prcp INTO final_record
                   FROM intersections i
                   LEFT JOIN data.daymet as d 
                   ON d.featureid=i.featureid
                 WHERE date_part('year'::text, date) >= $STARTYEAR
                   AND date_part('year'::text, date) <= $ENDYEAR;"
                
psql -d $DB -c  "\COPY final_record TO $RECORD WITH CSV HEADER;"

psql -d $DB -c "DROP TABLE final_record;
                DROP TABLE gage_sites;"