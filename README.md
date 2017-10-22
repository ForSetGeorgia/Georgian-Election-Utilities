# A set of scripts for https://data.electionsportal.ge

__This is a set of scripts and example files to generate the CSV file of
hierarchical shapes for the Georgian Election Data Portal.__

1. It is highly recommended that you ensure that all fields, such as the ID and
Name of each shape at every level be accessible in the shapefile as an attribute
to make it easier to process them.

Each level needs the ID and Name of the parent level and its own ID and Name as
as the shape in JSON form.

There is an example.csv file in the root of the repository to show the structure.

2. The main flow is:
    * simplify the shape files - use the simplify script to do that. It uses
    MapShaper from https://mapshaper.org/. You can adjust the amount of
    simplification that you need in the script. Don't forget that you don't put
    the .shp extension of the target file, just the basename of the file.
    * export the shapefiles to geojson format for further processing. There is
    a script to convert from shapefile to geojson called shapes2json in the
    root of the repository. That script, using gdal tools, also ensures the
    projection of the shapes is in Pseudo Mercador EPSG:3857.
    * create a yaml config file, an example of which is located in the root
    of the repository, that tells the json2csv script where to find the
    GEOJSON files and which attributes are the IDs and Names.

3. Cross your fingers and hope this works.
