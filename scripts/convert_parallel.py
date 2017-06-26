#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import datetime
import subprocess
from multiprocessing import Pool, Lock, Value

globallock = Lock()
script_path = os.path.dirname(os.path.realpath(__file__))
counter = Value('i', 0)

def proces_tile(path):
    """
    Process one tile
    """

    proc = subprocess.Popen([script_path + '/convert_tile.sh', path],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)

    output = proc.stdout.read()

    globallock.acquire()
    print "====================================================="
    print "Tile '{}' processed. Logs: ".format(path)
    print output
    counter.value -= 1
    print "{} tiles left".format(counter.value)
    globallock.release()

def main(rootdir):
    start = datetime.datetime.now()
    tiles = []
    for dirpath, subdirs, files in os.walk(rootdir):
        for x in files:
            if x.endswith(".osm"):
                tiles.append(os.path.join(dirpath, x))

    counter.value = len(tiles)
    tiles_pool = Pool(processes=4)

    print "Start pool for {} osm tiles".format(counter.value)

    tiles_pool.map(proces_tile, tiles)
    tiles_pool.close()
    stop = datetime.datetime.now()

    print "All tiles processed in {}".format(stop - start)

if __name__ == '__main__':
    counter = Value('i', 0)
    main(sys.argv[1])
