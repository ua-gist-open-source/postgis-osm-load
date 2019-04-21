#!/bin/bash

# Create database
psql -d arizona -c "create database arizona"

# Enable PostGIS spatial database
psql -d arizona -c "create extension postgis"
  
# Export from shapefile to sql
for f in $(ls *.shp|sed 's/.shp//'); do 
  shp2pgsql -s 4326 $f.shp > $f.sql 
done

# Rename tables
for f in $(ls *.sql | sed 's/gis_osm_//' | sed 's/_free.*//'); do 
  psql -d arizona -h localhost -U postgres -c "ALTER TABLE gs_osm_${tab}_free_1 RENAME TO ${tab};" 
done
