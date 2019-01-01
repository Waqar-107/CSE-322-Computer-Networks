#!/bin/bash

#tcl format 
#ns filename.tcl nodes flows packets coverage_of_node
nodes[0]=20
nodes[1]=40
nodes[2]=60
nodes[3]=80
nodes[4]=100

flow[0]=10
flow[1]=20
flow[2]=30
flow[3]=40
flow[4]=50

packets[0]=100
packets[1]=200
packets[2]=300
packets[3]=400
packets[4]=500

coverage[0]=0
coverage[1]=0
coverage[2]=0
coverage[3]=0
coverage[4]=0

output_file=wireless_static_802_15_4.out

#empty the file
truncate -s 0 $output_file

#vary nodes
echo "varying number of nodes. flow: ${flow[4]} packets: ${packets[4]} coverage: ${coverage[4]}" >> $output_file
for((i=4;i<5;i++))
do
    ns wireless_static_802_15_4.tcl ${nodes[$i]} ${flow[4]} ${packets[4]} ${coverage[4]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, node: ${nodes[$i]}" >> $output_file
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done

#vary flow
echo "varying number of flow. node: ${nodes[4]} packets: ${packets[4]} coverage: ${coverage[4]}" >> $output_file
for((i=5;i<5;i++))
do
    ns wireless_static_802_15_4.tcl ${nodes[4]} ${flow[$i]} ${packets[4]} ${coverage[4]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, flows: ${flow[$i]}" >> $output_file
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done

#vary packet
echo "varying number of packets. node: ${nodes[4]} flow: ${flow[4]} coverage: ${coverage[4]} " >> $output_file
for((i=5;i<5;i++))
do
    ns wireless_static_802_15_4.tcl ${nodes[4]} ${flow[4]} ${packets[$i]} ${coverage[4]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, packets: ${packets[$i]}" >> $output_file
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done

#vary coverage of node
echo "varying number of coverage. node: ${nodes[4]} flow: ${flow[4]} packets: ${packets[4]}" >> $output_file
for((i=5;i<5;i++))
do
    ns wireless_static_802_15_4.tcl ${nodes[4]} ${flow[4]} ${packets[4]} ${coverage[$i]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, coverage: ${coverage[$i]}" >> $output_file
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done