Query Daymet
============

# Description
The function of this tool is to query [Daymet](https://daymet.ornl.gov/) 
climate records from the sheds database for a user-provided list of site 
coordinates. For each of the sites provided, the tool returns one table 
with a daily time-series for all of the Daymet variables. Rather than 
accessing raw Daymet data, the tool queries the records associated with 
the hydrologic catchments as described in the 
[daymet repository](https://github.com/Conte-Ecology/shedsGisData/tree/master/daymet) of the SHEDS GIS Data Project. 
<br><br>


# Workflow

## Create Input Table
A CSV of the sites with associated latitude and longitude identifies which 
climate records to pull. The CSV table should be in the same format as Table 1. 

| site_no |     LONG	   |     LAT     |
| :-----: |     ----     |     ---     |
| 1F003	  | -78.26865877 | 38.70301594 |
| 1F007	  | -78.37064837 | 38.71212916 |
| 1F030	  | -78.27935884 | 38.69506642 |
| 1F118	  | -78.32445066 | 38.74835781 |
| 1F132   | -78.31918196 | 38.78955881 |
Table 1: A sample input table
<br><br>


## Execute script
The shell script accesses the Postgres database by using PostGIS functions to 
relate the sites to catchments based on spatial location. Execute the 
`query_daymet.sh` script in the bash. The script takes 5 arguments: database 
name, the file path to the input CSV, the file path to the climate table to be 
created, the start date, and the end date. Dates should be in the "yyyy-mm-dd" 
format.

Example: `./query_daymet.sh sheds /home/data/climate/sites.csv /home/data/climate/daymet_record.csv 1980-01-01 2010-12-31`
<br><br>


### Output
A CSV is generated with the records for the sites provided over the specified 
dates. The table contains one record for each variable per site/date combination.

| site_no | featureid |   date   |   tmax  |	 tmin   | prcp | dayl	 | srad	   |  vp     | swe |
| :-----: | :-------: |   :--:   |   :--:  |   :--:   | :--: | :--:  | :--:    | :--:    | :-: |
| 1539000	| 202997089	| 1/1/1982 | 4.33333 | -4.16667	| 6    | 32832 | 129.067 | 440	   | 0   |
| 1539000	| 202997089	| 1/2/1982 | 3       | -6.83333	| 6    | 32832 | 160     | 360	   | 8   |
| 1539000	| 202997089	| 1/3/1982 | 1.16667 | -6.66667	| 0    | 32832 | 182.4   | 360	   | 8   |
| 1539000	| 202997089	| 1/4/1982 | 7.33333 | -1.66667	| 19   | 32832 | 150.4   | 546.667 | 4   |
| 1539000	| 202997089	| 1/5/1982 | 7.5     | -2.5	    | 4    | 32832 | 161.067 | 520     | 4   |
Table 2: A sample output table
<br><br>


# Contact Info
Kyle O'Neil  
koneil@usgs.gov  
