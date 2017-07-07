# OSM buildings to Cesium 3d tiles converter

## How it works

1. Split and filter OSM into tiles using https://github.com/kiselev-dv/gazetteer

    It will change 1.1. step if you use pbf dump. 
    If you don't have enough RAM edit script to add `--disk-index` after `tile-buildings`.

    1.1 `java -jar /opt/gazetteer/gazetteer.jar --data-dir /opt/data split /opt/data/map.osm.bz2`

    1.2 `java -jar /opt/gazetteer/gazetteer.jar --data-dir /opt/data tile-buildings --out-dir /opt/osm-tiles --level 12`

2. Convert each tile into smaller obj tiles, generate cesium `tileset.json` metafile using https://github.com/kiselev-dv/OSM2World

    It uses patched version of OSM2World which supports tiled obj output and generates metadata for Cesium.

    Original script do that in several threads, to speadup the process. If you want to run OSM2World manually:

    2.1 `cd /opt/OSM2World` it's necessary for `osm2world.sh` to link libs on the right paths.

    2.2 `./osm2world.sh -i /opt/osm-tiles/{zoom}/{x}/{y}.osm -o /opt/obj-tiles/dummy.obj`

    It will create /opt/obj-tiles/14/* tiles, /opt/obj-tiles/14/tileset.json and /opt/obj-tiles/14/dummy.mtl
    Original script, will create different mtl and tileset.json files for each osm tile.

3. Convert obj into binary gltf using https://github.com/AnalyticalGraphicsInc/obj2gltf
4. Convert binary gltfs into b3dms using https://github.com/AnalyticalGraphicsInc/3d-tiles-tools
5. Create one meta tileset for each osm subtileset.

## Build

This project adds some bash scripts to glue togeter projects mentioned above and can be used as is without building. 

But you'll need a special versions of OSM2World and gazetteer. 
So there is also a Dockerfile wich install all the neccessary projects and build them.

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

