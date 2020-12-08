# Assignment: PostGIS - OSM Data Load
## Worth: 50 points

## Background
_[OpenStreetMap](https://www.openstreetmap.org) (aka OSM) is a map of the world, created by people like you and free to use under an open license._ In this lab you are going to download the OSM data for the state of Hawaii and load it into a
PostGIS Database. 
- Nov 2020 article noting recent heavy corporate investment in OSM [link](https://joemorrison.medium.com/openstreetmap-is-having-a-moment-dcc7eef1bb01)

## Deliverables
`osm`
- `import.cmd` (or `import.sh` for linuz/osx users) in a `osm` branch with a Pull Request to merge with master.
- `osm_qgis_screenshot.png` - A screenshot of QGIS showing the OSM layers loaded from PostGIS, zoomed into Tucson.

`import.cmd` (or `import.sh` for linux/mac users) should contain all commands used to import the data into PostgreSQL. In practice, this file would be a functioning shell script that could be re-used to perform the full data import from the  unzipped shapefile to having fully populated tables in PostgreSQL.

## Prerequisites
Postgres with PostGIS is running. For this assignment we are running it in a docker container like we set up in a previous assignment:
```
docker run --name postgis -d -v $HOME/postgres_data/data:/var/lib/postgresql/data -p 25432:5432 mdillon/postgis
```
Note that if you still have a database running from before, you will get an error about the port being used. If the database is still running, you should be able to disregard this error. 

## Quick Note on PostgreSQL environment
When you connect to the database you must provide `username`, `password` `hostname`, `port`, and `database`. For 
command line programs these will be set to defaults if not provided. These are the defaults for `psql`:
- username: whatever you're currently logged in as (i.e., your windows/mac/linux username)
- password: you can create a default password by adding an environment variable PGPASSWORD
- hostname: `localhost`
- port: `5432`
- database: same as your username

These can be overriden in psql by adding command line switches:

`psql -U $USERNAME -h $HOST -d $DATABASE`

### OpenStreetMap Data Model
Read about the OSM Data Model at [https://labs.mapbox.com/mapping/osm-data-model/](https://labs.mapbox.com/mapping/osm-data-model/). OSM Treats the world as vectors, specifically using the terminology `nodes`, `ways`, and `relations`. It does not 
map perfectly to the `points`, `lines`, and `polygons` models that you are used to. The model is also somewhat loosely defined and classes of entities such as roads are separated logically into different groups. Instead, they are represented by special attributes. Translating these entities to spatial layers requires a bit of work.

### Download OpenStreetMap Hawaii data

Download the Hawaii _shapefile_ (not the pbf file) for OpenStreetMap from [http://download.geofabrik.de/north-america/us/hawaii.html](http://download.geofabrik.de/north-america/us/hawaii.html). It will be named `hawaii-latest-free.shp.zip`.

Unzip and take note of the projection:

```GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]]```

This is `EPSG:4326`.

### Create a `hawaii` database
Create a database for the OSM Data. You can do this through pgadmin but to make things more deterministic, type the following in a command window. Note that most of the following command is cruft required to pass the command to the server. The relevant SQL is simply `CREATE DATABASE hawaii`:

```
docker run --link postgis:postgres --entrypoint sh mdillon/postgis -c 'psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p $POSTGRES_PORT_5432_TCP_PORT -U postgres -c "CREATE DATABASE hawaii"'
```

Next, enable the `PostGIS` extension. The command is simply `CREATE EXTENSION postgis` but you pass `-d hawaii` to make it happen in that new database. Submit it like:

```
docker run --link postgis:postgres --rm --entrypoint sh mdillon/postgis -c 'psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p $POSTGRES_PORT_5432_TCP_PORT -U postgres -d hawaii -c "CREATE EXTENSION postgis"'
```


### Extract the OSM data and load it into postgresql

The command to load this data into PostGIS is called `shp2psql`. You used that in the `nyc`-based workshop tutorial before. It is a command that takes a shapefile and turns into the PostgreSQL variant of SQL. When you run it you
you will provide the name of a shapefile. By default the output will be printed to your screen (aka `STDOUT`) but you want to redirect the output to a file. 

**Note: This section can be handled using the GUI Shapefile Importer used in the NYC PostGIS Tutorial**

We are going to utilize the same postgis container, since it contains the `shp2pgsql` program. However, when we run it, it will be a _second_ container and it will need to know how to connect to the first container. Docker allows running containers to know about each other by _linking_ them. When they are linked, the exposed parts of the container will be accessible through _environment variables_. In the command below, pay special attention to:
- `--link postgis:postgres` -- this tells this container to link with the `postgis` named container (remember we gave it `--name postgis` before)
- `-v $HOME/Downloads/hawaii-latest-free.shp:/data` -- this is volume sharing and may differ for you, depending where you extracted the `hawaii-latest-free.shp.zip` file to.
- `$POSTGRES_PORT_5432_TCP_ADDR` is the internal network address of the postgis container (inside docker's own private network)
- `$POSTGRES_PORT_5432_TCP_PORT` is the port that is exposed on that container corresponding to the internal 5432 port.

Running it through docker requires a little extra cruft to make it run. That extra docker stuff is at the beginning:
```docker run --link postgis:postgres --rm -v $HOME/Downloads/hawaii-latest-free.shp:/data --entrypoint sh  mdillon/postgis -c '....'``` 
Then the part after -`c` inside the single quotes is the actual command that will be run inside that container, which is essentially: `shp2pgsql | psql` which extracts the shapefile into SQL and then inserts it into the database.
```
docker run --link postgis:postgres --rm -v $HOME/Downloads/hawaii-latest-free.shp:/data  --entrypoint sh mdillon/postgis -c 'shp2pgsql -s 4326 -c -g geom /data/gis_osm_waterways_free_1.shp public.waterways | psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p $POSTGRES_PORT_5432_TCP_PORT -U postgres -d hawaii'
```
A successful run will result in a large number of lines with nothing else but 
```
INSERT 0 1
```

The above two commands will create and populate a table for `waterways` based on OSM data. Note this appears in two places in the command: 
- `gis_osm_waterways_free_1.shp` which is the name of the shapefile. You'll have to match each of the shapefiles that you extracted in the zip. 
- `public.waterways` which is the target table for this data. You can name that whatevery you want but it would best to be simple but also get rid of the extra `gis_osm_` prefix and `_free_1` suffix. Note that the word `natural` is a keyword in postgres so you cannot choose that name as an output table name.

You can check on the data in pgAdmin. If it looks good, do the same for the rest of the shapefiles in that directory.

Repeat the steps for the additional data files. Refresh your pgadmin table list to see that the tables were created. It can take a few minutes for the larger tables but should not take longer than 15 minutes total. I encourage choosing the following renaming conventions:
```
gis_osm_buildings_a_free_1.shp -> buildings_a
gis_osm_landuse_a_free_1.shp -> landuse_a
gis_osm_natural_a_free_1.shp -> nature_a
gis_osm_natural_free_1.shp -> nature
gis_osm_places_a_free_1.shp -> places_a
gis_osm_places_free_1.shp -> places
gis_osm_pofw_a_free_1.shp -> pofw_a
gis_osm_pofw_free_1.shp -> pofw
gis_osm_pois_a_free_1.shp -> pois_a
gis_osm_pois_free_1.shp -> pois
gis_osm_railways_free_1.shp -> railways
gis_osm_roads_free_1.shp -> roads
gis_osm_traffic_a_free_1.shp -> traffic_a
gis_osm_traffic_free_1.shp -> traffic
gis_osm_transport_a_free_1.shp -> transport_a
gis_osm_transport_free_1.shp -> transport
gis_osm_water_a_free_1.shp -> water_a
gis_osm_waterways_free_1.shp -> waterways
```

Do this for all the OSM layers. Tables containing `_a_` in them refer to polygons; hence some feature classes are 
represented both as points (e.g., `places`) and polygons (e.g., `places_a`). 

*Note: `natural` is a postgresql reserved word do rename `gis_osm_natural_free_1` to `nature`*

### Open PostGIS Tables as Layers in QGIS
Open GGIS and select the `Layer` -> `Add PostGIS Layers` option. 
Open all the OSM Hawaii layers. Take a screenshot and save it to your github `osm` branch with the name `osm_qgis_screenshot.png`

### Deliverables:
The following two files in a branch named `osm`, submitted as a Pull Request to be merged with master:
1) File named `import.cmd` containing:
- all commands used to extract shapefile data into sql files (i.e. those , `shp2pgsql...`)
- all commands used to import sql files into postgresql (i.e., `psql...`)
2) Screenshot named `osm_qgis_screenshot.png` showing all OSM PostGIS tables visible in QGIS, zoomed into Tucson

[![DOI](https://zenodo.org/badge/181833899.svg)](https://zenodo.org/badge/latestdoi/181833899)
