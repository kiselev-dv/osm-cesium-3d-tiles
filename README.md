# OSM buildings to Cesium 3d tiles converter

## How it works

1. Split and filter OSM into tiles using https://github.com/kiselev-dv/gazetteer
2. Convert each tile into smaller obj tiles, generate cesium tileset.json metafile using https://github.com/kiselev-dv/OSM2World
3. Convert obj into binary gltf using https://github.com/AnalyticalGraphicsInc/obj2gltf
4. Convert binary gltfs into b3dms using https://github.com/AnalyticalGraphicsInc/3d-tiles-tools

## Build

This project adds some bash scripts to glue togeter projects mentioned above and can be used as is without building. 

But you'll need a special versions of OSM2World and gazetteer. So there is also a Dockerfile wich install all the neccessary projects and build them. `Dockerfile is outdated now`

## Run

Run `scripts/convert.sh` all parameters are passed as environment variables.

To override parameters: `PARAM1=/some/path PARAM2='some value' scripts/convert.sh`

If you use a local builded version of OSM2World, 
it's important to use OSM2World build directory as working dir.
It will allow osm2world.sh script to resolve lib paths correctly.

### Parameters

* `OSM_DUMP` - Path to osm dump. default: `/opt/data/map.osm.bz2`
* `GAZETTEER_JAR` - Path to gazetteer.jar default: `/opt/gazetteer/gazetteer.jar`
* `GAZETTEER_DATA_DIR` - Path, where gazetteer can store intermediate files. default: `/opt/data/gazetteer`
* `OSM_TILES` - Path where to store tiled osm files. default: `/opt/data/osm-tiles`
* `OBJ_TILES` - Path where to store tiled obj models. default: `/opt/data/obj-tiles`
* `OBJGLTF_BIN` - Path to obj2gltf.js node js script. default: `/opt/obj2gltf/bin/obj2gltf.js`
* `GLB_BIN` - Path to 3d-tiles-tools.js node js script. default: `/opt/3d-tiles-tools/tools/bin/3d-tiles-tools.js`
* `OSMW_BIN` - Path to osm2world.sh shell script. default: `/opt/osm2world.sh`
* `OSMW_CONF` - Path to osm2world prop.properties template file. You can use `scripts/prop.properties` as template. default: `/opt/scripts/prop.properties`

