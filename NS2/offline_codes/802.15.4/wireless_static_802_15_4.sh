#!/bin/bash

#tcl format 
#ns filename.tcl nodes flows packets coverage_area
nodes=100
flow=50
packets=100
coverage=250

ns wireless_static_802_15_4.tcl $nodes $flow $packets $coverage
#nam wireless_static_802_15_4.nam