#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
from os import listdir
from os.path import isfile, join, basename

def list_tilesets(dir_path):
    print "Looking for tilesets in {}".format(dir_path)
    return [join(dir_path, f)
            for f
            in listdir(dir_path)
            if isfile(join(dir_path, f)) and f.endswith("tileset.json") and f != "tileset.json"]

def read_tileset(path):
    with open(path) as data_file:
        return json.load(data_file)

def main(dir_path):
    child_tilesets = []
    root_region = []
    root_error = 0
    for p in list_tilesets(dir_path):
        filename = basename(p)
        tileset_json = read_tileset(p)
        region = tileset_json['root']['boundingVolume']['region']

        # Skip empty regions
        if region[4] != 0.0 or region[5] != 0.0:
            # Update root region
            if len(root_region) == 0:
                root_region = region
            else:
                # west north east south minH maxH
                root_region[0] = min(root_region[0], region[0])
                root_region[1] = min(root_region[1], region[1])
                root_region[2] = max(root_region[2], region[2])
                root_region[3] = max(root_region[3], region[3])
                root_region[4] = min(root_region[4], region[4])
                root_region[5] = max(root_region[5], region[5])
            child_err = tileset_json['root']['geometricError']
            root_error += child_err
            child = {
                "geometricError": child_err,
                "boundingVolume": {
                    "region": region
                },
                "content": {
                    "url": filename
                }
            }
            child_tilesets.append(child)
        else:
            print "Tileset {} is empty.".format(p)

    if len(child_tilesets) > 0:
        root_tileset = {
            "asset": {
                "version": "0.0"
            },
            "geometricError": root_error,
            "boundingVolume": {
                "region": root_region
            },
            "root": {
                "refine": "ADD",
                "boundingVolume": {
                    "region": root_region
                },
                "geometricError": root_error,
                "children": child_tilesets
            }
        }

        with open(join(dir_path, 'tileset.json'), 'w') as outfile:
            json.dump(root_tileset, outfile)
            print "{} child tilesets writen to tileset.json".format(len(child_tilesets))
    else:
        print "No child tilesets found"

if __name__ == "__main__":
    main(sys.argv[1])
