#!/bin/bash

# num_of_packet speed_of_node
ns 802_11_mixed.tcl 500 25
awk -f 802_11_mixed.awk 802_11_mixed.tr
nam 802_11_mixed.nam