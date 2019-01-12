#!/bin/bash

s[0]="rThroughput"
s[1]="rAverageDelay"
s[2]="nSentPackets"
s[3]="nReceivedPackets"
s[4]="nDropPackets"
s[5]="rPacketDeliveryRatio"
s[6]="rPacketDropRatio"
s[7]="rTime"

s[8]="total_energy_consumption"
s[9]="avg_energy_per_bit"
s[10]="avg_energy_per_byte"
s[11]="avg_energy_per_packet"
s[12]="total_retransmit"
s[13]="rEnergyEfficeincy"

for((i=0;i<14;i++))
do
    arr[$i]=0
done

for((i=0;i<10;i++))
do
    j=0
    ns wireless_mobile_802_11_tcp.tcl 100 50 500 25
    for val in $(awk -f wireless_mobile_802_11_tcp.awk wireless_mobile_802_11_tcp.tr)
    do
        temp=$(echo "scale=5; $val" | bc)

        temp2=$(echo "scale=5; $temp+${arr[$j]}" | bc)
        arr[$j]=$temp2

        #echo ${arr[$j]}
        j=$(($j+1))
        #echo "j " $j

        
    done
done

for((i=0;i<14;i++))
do
    temp=$(echo "scale=5; ${arr[$i]}/10" | bc)
    echo ${s[i]} " : " $temp
done

