#!/bin/bash

output_file=wireless_mobile_802_11_tcp.out

#empty the file
truncate -s 0 $output_file

ns wireless_mobile_802_11_tcp.tcl 100 50 500 25
awk -f wireless_mobile_802_11_tcp.awk wireless_mobile_802_11_tcp.tr >> $output_file
