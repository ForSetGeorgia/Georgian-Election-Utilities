
1. Run this on shapefile to convert projection to 3857
ogr2ogr -f "GeoJSON" -t_srs EPSG:3857 ogr/precinct.geojson precinct.shp

2. Import into QGIS and export as GEOJSON as is. Don't change the


ogr2ogr -f "GeoJSON" output.json input.shp
