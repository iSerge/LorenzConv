#!/usr/local/bin/python3

import fileinput

for line in fileinput.input():
    print (line.replace(',','.'))
