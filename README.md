
## OpenStreetMap Arizona

Download the Arizona shapefile for OpenStreetMap from [http://download.geofabrik.de/north-america/us/arizona.html](http://download.geofabrik.de/north-america/us/arizona.html).

Unzip and take note of the projection:

GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]]

This is EPSG:4326.

The command to load this data into PostGIS is called shp2psql.


```
shp2pgsql -s 4326 gis_osm_places_free_1 > gis_osm_places_free_1.sql
```


This creates a SQL file that you can use to load the data into postgresql. Loading data via the command line is pretty simple:


```
psql -d gist604b -h localhost -U postgres -f gis_osm_places_free_1.sql
```


There are a lot of files to work with so let’s use this script to run them all in one go:


```
for /F %i in ('dir /B *.shp') do shp2pgsql -s 4326 %i %~ni > %~ni.sql
```




<p id="gdcalert16" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/GIST-604B15.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert17">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/GIST-604B15.png "image_tooltip")



### NOTE ASSIGNMENT DELIVERABLE #1

**Screenshot showing output of the shp2pgsql output or a full list of the commands used**

Look in Windows explorer and confirm the SQL files have been created.



<p id="gdcalert17" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/GIST-604B16.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert18">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/GIST-604B16.png "image_tooltip")


Next, batch create the tables from the .sql files:


```
set PGPASSWORD=postgres

for /F %i in ('dir /B *.sql') do psql -d gist604b -h localhost -U postgres -f %i
```


The commands will look like this:



<p id="gdcalert18" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/GIST-604B17.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert19">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/GIST-604B17.png "image_tooltip")



### NOTE ASSIGNMENT DELIVERABLE #2

**Screenshot showing output of the psql output or a full list of the commands used**

The names are pretty obnoxious since they all start with the same 8 characters. To change a table name in SQL: 


```
ALTER TABLE my_table RENAME TO new_name;
```


Use it with psql to run it from the command line:


```
psql -d gist604b -h localhost -U postgres -c "ALTER TABLE gs_osm_buildings_a_free_1 RENAME TO buildings;
```


Do this for all the OSM layers. I didn’t do it for the rest of this tutorial but it will make things a lot easier for you.


### Open PostGIS Tables as Layers in QGIS and Style


#### 

<p id="gdcalert19" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/GIST-604B18.png). Store image on your image server and adjust path/filename if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert20">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/GIST-604B18.png "image_tooltip")



#### Assignment

Open the OSM Arizona layers. Use your expert cartographic skills to customize the styles and create SLDs for each layer. Import the SLDs into geoserver. Create a workspace for the Arizona OSM named “`osm`”. Create layers in the `osm` workspace for each of the OSM tables using a PostGIS DataStore. Apply the appropriate SLDs to each layer. Finally, create a LayerGroup containing the layers. 

The deliverables for the assignment will be:



1. Screenshot showing output of the shp2pgsql output or a full list of the commands used
2. Screenshot showing output of the psql output or a full list of the commands used
3. Screenshot of the PostGIS tables viewed as layers in GQIS
4. Screenshot of geoserver UI showing the list of osm layers
5. Screenshot of a WMS request against the LayerGroup

