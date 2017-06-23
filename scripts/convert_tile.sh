#!/bin/bash

: ${OBJ_TILES:="/opt/data/obj-tiles"}
: ${GLB_BIN:="/opt/3d-tiles-tools/tools/bin/3d-tiles-tools.js"}
: ${OSMW_BIN:="/opt/osm2world.sh"}
: ${OSMW_CONF:="/opt/scripts/prop.properties"}
: ${OBJGLTF_BIN:="/opt/obj2gltf/bin/obj2gltf.js"}

TMS=$(echo $1 | grep -o '\/[0-9]*\/[0-9]*\/[0-9]*')

Z=$(echo "$TMS" | cut -d/ -f2 )
X=$(echo "$TMS" | cut -d/ -f3 )
Y=$(echo "$TMS" | cut -d/ -f4 )

echo "Run OSM2World for ${OSM_TILES}${TMS}.osm output to $OBJ_TILES/dummy.obj"

# Edit tileset path in OSMW_CONF
cat ${OSMW_CONF} | grep --invert-match 'cesiumTileset.*=' > ${OBJ_TILES}/${Z}_${X}_${Y}.properties
echo "cesiumTileset = ${OBJ_TILES}/${Z}_${X}_${Y}_tileset.json" >> ${OBJ_TILES}/${Z}_${X}_${Y}.properties

$OSMW_BIN -i $1 -o $OBJ_TILES/dummy.obj --config ${OBJ_TILES}/${Z}_${X}_${Y}.properties

echo "Convert generated objs to glb"
find $OBJ_TILES -type f -iname '*.obj' | xargs -I {} -n 1 node ${OBJGLTF_BIN} --binary --optimizeCesium -i {} -o {}.glb 
find $OBJ_TILES -type f -iname '*.glb' | grep -o ".*/[0-9]*/[0-9]*/[0-9]*" | xargs -n 1 -I {} mv {}.obj.glb {}.glb

echo "Convert generated glb to b3dm"
find $OBJ_TILES -type f -iname '*.glb' | grep -o ".*/[0-9]*/[0-9]*/[0-9]*" | xargs -n 1 -I {} node $GLB_BIN glbToB3dm {}.glb {}.b3dm

echo "Remove intermediate files"
rm ${OBJ_TILES}/${Z}_${X}_${Y}.properties
find $OBJ_TILES -type f -iname '*.obj' -delete
find $OBJ_TILES -type f -iname '*.glb' -delete