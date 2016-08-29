PostGIS Tools
=============

This repository houses scripts for the spatial tools and processes in the 
postgres database. The tools take advantage of the spatial features provided 
in PostGIS, the spatial component of Postgres databases.
<br><br>


# Tools

## Query Daymet
Daymet records are returned for a set of lat/lon points (NAD83). One CSV of 
climate variable timeseries is generated for all of the sites specified. The  
hydrologically assigned Daymet records are accessed by this tool, not the raw 
Daymet records.
<br><br>

## Zonal Statistics
The average values from a raster are calculated for a layer of polygons. This 
is set up specifically for the `catchments` table in the sheds database. The 
tool is adaptation of the process previously run in ArcGIS.
<br><br>

# Contact Info
Kyle O'Neil  
koneil@usgs.gov  
