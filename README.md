# Assignment: PostGIS - OSM Data Load
## Worth: 50 points

## Background
_[OpenStreetMap](https://www.openstreetmap.org) (aka OSM) is a map of the world, created by people like you and free to use under an open license._ In this lab you are going to download the OSM data for the state of Arizona and load it into a
PostGIS Database. 

## Deliverables
`osm`
- `import.cmd` (or `import.sh` for linuz/osx users) in a `osm` branch with a Pull Request to merge with master.
- `osm_qgis_screenshot.png` - A screenshot of QGIS showing the OSM layers loaded from PostGIS, zoomed into Tucson.

`import.cmd` (or `import.sh` for linux/mac users) should contain all commands used to import the data into PostgreSQL. In practice, this file would be a functioning shell script that could be re-used to perform the full data import from the  unzipped shapefile to having fully populated tables in PostgreSQL.

## Prerequisites
Postgresql with PostGIS should be installed. 
`psql` should be in your path (windows users: You may need to add C:\Program Files\PostgreSQL\9.6\bin (or whatever directory you installed Postgresql to) to your Windows PATH). 

## Quick Note on PostgreSQL environment
When you connect to the database you must provide `username`, `password` `hostname`, `port`, and `database`. For 
command line programs these will be set to defaults if not provided. These are the defaults for `psql`:
- username: whatever you're currently logged in as (i.e., your windows/mac/linux username)
- password: you can create a default password by adding an environment variable PGPASSWORD
- hostname: localhost
- port: 5432
- database: same as your username

These can be overriden in psql by adding command line switches:

`psql -U $USERNAME -h $HOST -p $PASSWORD -d $DATABASE`

Note that password cannot be added as a command line argument in this case. If you want to save your password so you're not prompted every time, run this before you run `psql` or add the variables permanently to your environment through the control panel or shell profile:

Windows users:
```SET PGPASSWORD='your_password_here'```

Linux users:
```export PGPASSWORD='your_password_here'```

### OpenStreetMap Data Model
Read about the OSM Data Model at [https://labs.mapbox.com/mapping/osm-data-model/](https://labs.mapbox.com/mapping/osm-data-model/). OSM Treats the world as vectors, specifically using the terminology `nodes`, `ways`, and `relations`. It does not 
map perfectly to the `points`, `lines`, and `polygons` models that you are used to. The model is also somewhat loosely defined and classes of entities such as roads are separated logically into different groups. Instead, they are represented by special attributes. Translating these entities to spatial layers requires a bit of work.

### Download OpenStreetMap Arizona data

Download the Arizona _shapefile_ (not the pbf file) for OpenStreetMap from [http://download.geofabrik.de/north-america/us/arizona.html](http://download.geofabrik.de/north-america/us/arizona.html).

Unzip and take note of the projection:

```GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]]```

This is `EPSG:4326`.

### Create an `arizona` database
Create a database for the OSM Data. You can do this through pgadmin but to make things more deterministic, type the following in a command window:

```psql -U postgres -d arizona -c "create database arizona"```

You will be prompted for your password each time. To avoid being asked repeatedly, type the following command to store
your password in your local shell environment, replacing `postgres` with the password you selected (if you did) for your
PostgreSQL installation.

```
set PGPASSWORD=postgres
```

Note that if you close the window you will lose that environment. Thus, if you close and re-open a command window you will
need to re-issue the above command if you want to avoid being asked for the password every time you run a `psql` command. Savvy users can save this as a USER environment variable and not have to be asked again.

Next, enable the `PostGIS` extension:

```psql  -U postgres -d arizona -c "create extension postgis"```


### Extract the OSM data and load it into postgresql

The command to load this data into PostGIS is called `shp2psql`. It should already be installed as part of the PostGIS bundle. It is a command that takes a shapefile and turns into the PostgreSQL variant of SQL. When you run it you
you will provide the name of a shapefile. By default the output will be printed to your screen (aka `STDOUT`)
but you want to redirect the output to a file. 

**Note: This section can be handled using the GUI Shapefile Importer used in the NYC PostGIS Tutorial**

Open a Unix shell or DOS command window and navigate to the directory where you unzipped the arizona

```
shp2pgsql -s 4326 gis_osm_places_free_1 > gis_osm_places_free_1.sql
```

This creates a SQL file that you can use to load the data into postgresql. Loading data via the command line is pretty simple:

```
psql -U postgres -d arizona -h localhost -f gis_osm_places_free_1.sql
```
A successful run will result in a large number of lines with nothing else but 
```
INSERT 0 1
```

The above two commands will create and populate a table for `places` based on OSM data. 

Repeat the steps for the additional data files. Refresh your pgadmin table list to see that the tables were created. It can take a few minutes for the larger tables but sould not take longer than 15 minutes total.

### Rename the tables
The names are pretty obnoxious since they all start with the same 8 characters. To change a table name in SQL: 


```
ALTER TABLE my_table RENAME TO new_name;
```


Use it with psql to run it from the command line:


```
psql -U postgres -d arizona -h localhost -c "ALTER TABLE gis_osm_buildings_a_free_1 RENAME TO buildings;
```


Do this for all the OSM layers. Tables containing `_a_` in them refer to polygons; hence some feature classes are 
represented both as points (e.g., `places`) and polygons (e.g., `places_a`). 

*Note: `natural` is a postgresql reserved word do rename `gis_osm_natural_free_1` to `nature`*

### Open PostGIS Tables as Layers in QGIS
Open GGIS and select the `Layer` -> `Add PostGIS Layers` option. 
Open all the OSM Arizona layers. Take a screenshot and save it to your github `osm` branch with the name `osm_qgis_screenshot.png`

### Deliverables:
The following two files in a branch named `osm`, submitted as a Pull Request to be merged with master:
1) File named `import.cmd` containing:
- all commands used to extract shapefile data into sql files (i.e., `shp2pgsql...`)
- all commands used to import sql files into postgresql (i.e., `psql...`)
- all commands used to rename tables (i.e., `psql.... ALTER TABLE...`)
2) Screenshot named `osm_qgis_screenshot.png` showing all OSM PostGIS tables visible in QGIS, zoomed into Tucson

[![DOI](https://zenodo.org/badge/181833899.svg)](https://zenodo.org/badge/latestdoi/181833899)
