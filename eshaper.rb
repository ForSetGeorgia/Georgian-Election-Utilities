#!/usr/bin/env ruby

require_relative 'lib'

path = ARGV.shift
@date = Time.now.strftime("%Y%m%d")

# check existence of path argument
arg_check(path)

# script dependencies
dependencies = ['ogr2ogr', 'node', 'mapshaper']

# check for depencies on local OS
check_dependencies(dependencies)

# clean shapefile names
rename_shapefiles(path)

# simplify shapefiles
simplify_shapefiles(path, 15)

# convert shapefile to geojson format
shape2json(path)

# convert geojson to csv template for Election Data Portal
# see example csv file format: example.csv
json2csv(json_file)
