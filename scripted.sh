#!/bin/bash

STATE=arizona
USER=postgres

# Get latest copy of Arizona OSM shapefile
curl http://download.geofabrik.de/north-america/us/${STATE}-latest-free.shp.zip -o ${STATE}-latest-free.shp.zip

# Unzip
unzip ${STATE}-latest-free.shp.zip

cd ${STATE}-latest-free.shp

# Create database
psql -d ${STATE} ${USER} -c "create database arizona"

# Enable PostGIS spatial database
psql -d ${STATE} ${USER} -c "create extension postgis"
  
# Export from shapefile to sql
for f in $(ls *.shp|sed 's/.shp$//'); do 
  shp2pgsql -s 4326 $f.shp > $f.sql 
done

# Rename tables
for tab in $(ls *.sql | sed 's/^gis_osm_//' | sed 's/_free.*//'); do 
  OLD_NAME=gis_osm_${tab}_free_1
  if [[ $tab = "natural" ]]; then
    NEW_NAME="nature"
  else
    NEW_NAME=$tab
  psql -d ${STATE} -h localhost -U ${USER} -c "ALTER TABLE $OLD_NAME RENAME TO ${NEW_NAME};" 
done
