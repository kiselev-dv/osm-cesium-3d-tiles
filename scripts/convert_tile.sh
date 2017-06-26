#!/bin/bash

: ${OBJ_TILES:="/opt/data/obj-tiles"}
: ${GLB_BIN:="/opt/3d-tiles-tools/tools/bin/3d-tiles-tools.js"}
: ${OSMW_BIN:="/opt/osm2world.sh"}
: ${OSMW_CONF:="/opt/scripts/prop.properties"}
: ${OBJGLTF_BIN:="/opt/obj2gltf/bin/obj2gltf.js"}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMS=$(echo $1 | grep -o '\/[0-9]*\/[0-9]*\/[0-9]*')

Z=$(echo "$TMS" | cut -d/ -f2 )
X=$(echo "$TMS" | cut -d/ -f3 )
Y=$(echo "$TMS" | cut -d/ -f4 )

echo "Run OSM2World for ${OSM_TILES}${TMS}.osm output to $OBJ_TILES"

# Edit tileset path in OSMW_CONF
cat ${OSMW_CONF} | grep --invert-match 'cesiumTileset.*=' > ${OBJ_TILES}/${Z}_${X}_${Y}.properties
TILESET="${OBJ_TILES}/${Z}_${X}_${Y}_tileset.json"
echo "cesiumTileset = ${TILESET}" >> ${OBJ_TILES}/${Z}_${X}_${Y}.properties

# Use unique name for output obj, because it will be used for matherial file name
# and conversion goes in parallel threads, so we don't want to mess mtl files.
$OSMW_BIN -i $1 -o $OBJ_TILES/${Z}_${X}_${Y}.obj --config ${OBJ_TILES}/${Z}_${X}_${Y}.properties

echo "Convert generated objs to glb"
for tms in $(python ${DIR}/tms_from_tileset.py ${TILESET}); do
    echo "Convert ${OBJ_TILES}/${tms}.obj to glb"
    node ${OBJGLTF_BIN} --binary --optimizeCesium -i ${OBJ_TILES}/${tms}.obj -o ${OBJ_TILES}/${tms}.glb
    if [ -f ${OBJ_TILES}/${tms}.glb ]; then
        echo "Convert ${OBJ_TILES}/${tms}.glb to b3dm"
        node $GLB_BIN glbToB3dm ${OBJ_TILES}/${tms}.glb ${OBJ_TILES}/${tms}.b3dm
    fi
done
