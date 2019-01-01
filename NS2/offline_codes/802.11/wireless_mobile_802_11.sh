#!/bin/bash

#tcl format 
#ns filename.tcl nodes flows packets speed_of_node
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

speed[0]=5
speed[1]=10
speed[2]=15
speed[3]=20
speed[4]=25

output_file=wireless_mobile_802_11.out

#empty the file
truncate -s 0 $output_file

#vary nodes
echo "varying number of nodes. flow: ${flow[4]} packets: ${packets[4]} speed: ${speed[4]}" >> $output_file
for((i=0;i<5;i++))
do
    ns wireless_mobile_802_11.tcl ${nodes[$i]} ${flow[4]} ${packets[4]} ${speed[4]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, node: ${nodes[$i]}" >> $output_file
    awk -f wireless_mobile_802_11.awk wireless_mobile_802_11.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done

#vary flow
echo "varying number of flow. node: ${nodes[4]} packets: ${packets[4]} speed: ${speed[4]}" >> $output_file
for((i=0;i<5;i++))
do
    ns wireless_mobile_802_11.tcl ${nodes[4]} ${flow[$i]} ${packets[4]} ${speed[4]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, flows: ${flow[$i]}" >> $output_file
    awk -f wireless_mobile_802_11.awk wireless_mobile_802_11.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done

#vary packet
echo "varying number of packets. node: ${nodes[4]} flow: ${flow[4]} speed: ${speed[4]} " >> $output_file
for((i=0;i<5;i++))
do
    ns wireless_mobile_802_11.tcl ${nodes[4]} ${flow[4]} ${packets[$i]} ${speed[4]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, packets: ${packets[$i]}" >> $output_file
    awk -f wireless_mobile_802_11.awk wireless_mobile_802_11.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done

#vary speed of node
echo "varying number of speed. node: ${nodes[4]} flow: ${flow[4]} packets: ${packets[4]}" >> $output_file
for((i=0;i<5;i++))
do
    ns wireless_mobile_802_11.tcl ${nodes[4]} ${flow[4]} ${packets[4]} ${speed[$i]}
    echo "---------------------------------------------------------------------" >> $output_file
    echo "iteration: $i, speed: ${speed[$i]}" >> $output_file
    awk -f wireless_mobile_802_11.awk wireless_mobile_802_11.tr >> $output_file
    echo "---------------------------------------------------------------------" >> $output_file
    echo >> $output_file
done