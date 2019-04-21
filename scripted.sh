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
for f in $(ls *.sql | sed 's/^gis_osm_//' | sed 's/_free.*//'); do 
  psql -d ${STATE} -h localhost -U ${USER} -c "ALTER TABLE gs_osm_${tab}_free_1 RENAME TO ${tab};" 
done
