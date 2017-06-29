#! /usr/bin/env python
# -*- coding: utf-8 -*-

import json
import sys

def print_chld_path(chld):
    url = chld['content']['url']
    print url.replace('.b3dm', '')
    if 'children' in chld:
        for c in chld['children']:
            print_chld_path(c)

with open(sys.argv[1]) as data_file:
    data = json.load(data_file)
    for chld in data['root']['children']:
        print_chld_path(chld)
