#!/bin/bash

STATE=hawaii
DATABASE=hawaii

x=$(ls $HOME/Downloads/${STATE}-latest-free.shp/*.shp | cut -f6 -d/ | sed 's/gis_osm_//' | sed 's/_free_1.shp//' | awk '{ print "gis_osm_" $1 "_free_1.shp:" $1 }')
for ft in $x; do
  f=$(echo $ft | cut -f1 -d:)
  t=$(echo $ft | cut -f2 -d:)
  docker run --link postgis:postgres --rm -v $HOME/Downloads/${STATE}-latest-free.shp:/data  --entrypoint sh mdillon/postgis -c "shp2pgsql -s 4326 -c -g geom /data/$f public.$t | psql -h \$POSTGRES_PORT_5432_TCP_ADDR -p \$POSTGRES_PORT_5432_TCP_PORT -U postgres -d $DATABASE"
done
