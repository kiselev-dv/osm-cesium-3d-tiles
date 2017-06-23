#!/bin/bash

: ${OSM_DUMP:=/opt/data/map.osm.bz2}
: ${GAZETTEER_JAR:=/opt/gazetteer/gazetteer.jar}
: ${GAZETTEER_DATA_DIR:=/opt/data/gazetteer}

: ${OSM_TILES:="/opt/data/osm-tiles"}
: ${OBJ_TILES:="/opt/data/obj-tiles"}

: ${OBJGLTF_BIN:="/opt/obj2gltf/bin/obj2gltf.js"}
: ${GLB_BIN:="/opt/3d-tiles-tools/tools/bin/3d-tiles-tools.js"}
: ${OSMW_BIN:="/opt/osm2world.sh"}
: ${OSMW_CONF:="/opt/scripts/prop.properties"}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OPTIONS="OBJ_TILES=${OBJ_TILES} GLB_BIN=${GLB_BIN} OSMW_BIN=${OSMW_BIN} OSMW_CONF=${OSMW_CONF} OBJGLTF_BIN=${OBJGLTF_BIN}"
TILE_SCRIPT="${OPTIONS} ${DIR}/convert_tile.sh"

TILES_C=$(find ${OSM_TILES} -iname '*.osm' | wc -l)
if [ "$TILES_C" == "0" ]; then
    echo "Generate osm tiles"
    filename=$(basename "$OSM_DUMP")
    extension="${filename##*.}"
    if [ "$extension" == "bz2" ]; then
        bzcat ${OSM_DUMP} | java -jar ${GAZETTEER_JAR} split --data-dir ${GAZETTEER_DATA_DIR}
    elif [ "$extension" == "osm" ]; then
        java -jar ${GAZETTEER_JAR} split --data-dir ${GAZETTEER_DATA_DIR} ${OSM_DUMP}
    elif [ "$extension" == "pbf" ]; then
        osmconvert ${OSM_DUMP} | java -jar ${GAZETTEER_JAR} split --data-dir ${GAZETTEER_DATA_DIR}
    else 
        echo "Unrecognized osm dump file extension $extension"
    fi
    java -jar ${GAZETTEER_JAR} tile-buildings --out-dir ${OSM_TILES} --data-dir ${GAZETTEER_DATA_DIR}
fi

find ${OSM_TILES} -iname '*.osm' | xargs -n 2 $DIR/parallel_commands.sh "$TILE_SCRIPT $1" "$TILE_SCRIPT $2"