#! /usr/bin/env python
# -*- coding: utf-8 -*-

import json
import sys

with open(sys.argv[1]) as data_file:
    data = json.load(data_file)
    for chld in data['root']['children']:
        url = chld['content']['url']
        print url.replace('.b3dm', '')
