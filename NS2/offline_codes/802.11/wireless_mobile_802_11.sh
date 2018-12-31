#!/bin/bash

#tcl format 
#ns filename.tcl nodes flows packets speed_of_node
nodes=100
flow=50
packets=100
speed=25

ns wireless_mobile_802_11.tcl $nodes $flow $packets $speed