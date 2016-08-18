./query_daymet.sh sheds_new /home/kyle/postgis_tools/query_daymet/input/NEWAGBSites86.csv /home/kyle/postgis_tools/query_daymet/NEWAGBSites.csv 1982 2010





SELECT featureid, unnest(tmax), row_number()
from daymet 
where featureid in (20625492, 20625493)
and year in (1980, 1981);



SELECT featureid, year, unnest(tmax) into daytest
from daymet 
where featureid in (20625492, 20625493)
and year in (1980, 1981);


SELECT daytest*
from daymet 
where featureid in (20625492, 20625493)
and year in (1980, 1981);


SELECT i.site_no, d.featureid, d.year, unnest(d.tmax), unnest(d.tmin), unnest(d.prcp) INTO current_record
    FROM intersections i
    LEFT JOIN data.daymet as d 
    ON d.featureid=i.featureid
    WHERE year >= $STARTYEAR
    AND year <= $ENDYEAR;

  
SELECT *, row_number() OVER (PARTITION BY featureid, year);	
FROM current_record INTO final_record;

-- ADD DATE!
		
	
	