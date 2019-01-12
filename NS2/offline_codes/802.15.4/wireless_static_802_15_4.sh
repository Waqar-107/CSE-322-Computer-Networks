#!/bin/bash

outputDirectory="out/"
mkdir -p $outputDirectory
iteration_float=1.0;

graphData="$outputDirectory""GRAPH"

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

coverage[0]=1
coverage[1]=2
coverage[2]=3
coverage[3]=4
coverage[4]=5

dist[0]=200
dist[1]=225
dist[2]=250
dist[3]=500
dist[4]=1000

output_file=wireless_mobile_802_11.out
output_file2=metrics_calculation.out

#empty the file
truncate -s 0 $output_file
truncate -s 0 $output_file2
truncate -s 0 $graphData




#vary nodes
for((i=0;i<5;i++))
do


    nNodes=${nodes[$i]}
    nFlows=${flow[4]}
    pcktRate=${packets[4]}
    cover=${coverage[4]}

    l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
    dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;


    ns wireless_static_802_15_4.tcl $nNodes $nFlows $pcktRate $cover
    
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file

    while read val
        do

            l=$(($l+1))

            if [ "$l" == "1" ]; then
                thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
                #       echo -ne "throughput: $thr "
            elif [ "$l" == "2" ]; then
                del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
                #       echo -ne "delay: "
            elif [ "$l" == "3" ]; then
                s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
                #       echo -ne "send packet: "
            elif [ "$l" == "4" ]; then
                r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
                #       echo -ne "received packet: "
            elif [ "$l" == "5" ]; then
                d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
                #       echo -ne "drop packet: "
            elif [ "$l" == "6" ]; then
                del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
                #       echo -ne "delivery ratio: "
            elif [ "$l" == "7" ]; then
                dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
                #       echo -ne "drop ratio: "
            elif [ "$l" == "8" ]; then
                time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
                #       echo -ne "time: "
            elif [ "$l" == "9" ]; then
                t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
                #       echo -ne "total_energy: "
            elif [ "$l" == "10" ]; then
                energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_bit: "
            elif [ "$l" == "11" ]; then
                energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_byte: "
            elif [ "$l" == "12" ]; then
                energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_packet: "
            elif [ "$l" == "13" ]; then
                total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
                #       echo -ne "total_retrnsmit: "
            elif [ "$l" == "14" ]; then
                energy_efficiency=$(echo "scale=9; $energy_efficiency+$val/$iteration_float" | bc)
                #       echo -ne "energy_efficiency: "
            fi

            #echo "$val"
        done < $output_file

        # don't know what this is; found in sir's code
        enr_nj=$(echo "scale=2; $energy_efficiency*1000000000.0" | bc)


            # ==========================================================================
    # OUTPUT FILE GENERATION
    # ==========================================================================
    echo "######################################" >> $output_file2
    echo "# of Nodes:                   $nNodes " >> $output_file2
    echo "# of flows:                   $nFlows " >> $output_file2
    echo "Packet size:                  $pcktRate " >> $output_file2
    echo "Coverage                      $cover " >> $output_file2


    echo "" >> $output_file2

    echo "Throughput:                   $thr " >> $output_file2
    echo "AverageDelay:                 $del " >> $output_file2
    echo "Sent Packets:                 $s_packet " >> $output_file2
    echo "Received Packets:             $r_packet " >> $output_file2
    echo "Dropped Packets:              $d_packet " >> $output_file2
    echo "PacketDeliveryRatio:          $del_ratio " >> $output_file2
    echo "PacketDropRatio:              $dr_ratio " >> $output_file2
    echo "Total time:                   $time " >> $output_file2
    echo "Total energy consumption:     $t_energy " >> $output_file2
    echo "Average Energy per bit:       $energy_bit " >> $output_file2
    echo "Average Energy per byte:      $energy_byte " >> $output_file2
    echo "Average energy per packet:    $energy_packet " >> $output_file2
    echo "total_retransmit:             $total_retransmit " >> $output_file2
    echo "energy_efficiency(nj/bit):    $enr_nj " >> $output_file2
    echo "######################################" >> $output_file2
    echo "" >> $output_file2
    # ==========================================================================

    # ==========================================================================
    # GRAPH GENERATION
    # ==========================================================================
    echo -ne "$nNodes " >> $graphData      

    echo "$thr $del $del_ratio $dr_ratio $t_energy $energy_byte" >> $graphData


    truncate -s 0 $output_file

done
    arr[0]=""
    arr[1]="Throughput"
    arr[2]="Average Delay"
    arr[3]="Packet Delivery Ratio"
    arr[4]="Packet Drop Ratio"
    arr[5]="Total Energy consumption"
    arr[6]="Energy per byte"

    arr2[0]=""
    arr2[1]="Throughput ( bit/second )"
    arr2[2]="Average Delay ( second )"
    arr2[3]="Packet Delivery Ratio ( % )"
    arr2[4]="Packet Drop Ratio ( % )"
    arr2[5]="Total Energy consumption ( J )"
    arr2[6]="Energy per byte ( J )"

    for((i=1;i<7;i++))
    do
    gnuplot -persist -e "set title '802.11 : ${arr[$i]} vs No. of Nodes'; set xlabel 'No. of Nodes'; set ylabel '${arr2[$i]}'; plot 'out/GRAPH' using 1:$i+1 with lines"
    done
    truncate -s 0 $graphData




#vary flow
for((i=0;i<5;i++))
do


    nNodes=${nodes[4]}
    nFlows=${flow[$i]}
    pcktRate=${packets[4]}
    cover=${coverage[4]}

    l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
    dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;


    ns wireless_static_802_15_4.tcl $nNodes $nFlows $pcktRate $cover
    
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file

    while read val
        do

            l=$(($l+1))

            if [ "$l" == "1" ]; then
                thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
                #       echo -ne "throughput: $thr "
            elif [ "$l" == "2" ]; then
                del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
                #       echo -ne "delay: "
            elif [ "$l" == "3" ]; then
                s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
                #       echo -ne "send packet: "
            elif [ "$l" == "4" ]; then
                r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
                #       echo -ne "received packet: "
            elif [ "$l" == "5" ]; then
                d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
                #       echo -ne "drop packet: "
            elif [ "$l" == "6" ]; then
                del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
                #       echo -ne "delivery ratio: "
            elif [ "$l" == "7" ]; then
                dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
                #       echo -ne "drop ratio: "
            elif [ "$l" == "8" ]; then
                time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
                #       echo -ne "time: "
            elif [ "$l" == "9" ]; then
                t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
                #       echo -ne "total_energy: "
            elif [ "$l" == "10" ]; then
                energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_bit: "
            elif [ "$l" == "11" ]; then
                energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_byte: "
            elif [ "$l" == "12" ]; then
                energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_packet: "
            elif [ "$l" == "13" ]; then
                total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
                #       echo -ne "total_retrnsmit: "
            elif [ "$l" == "14" ]; then
                energy_efficiency=$(echo "scale=9; $energy_efficiency+$val/$iteration_float" | bc)
                #       echo -ne "energy_efficiency: "
            fi

            #echo "$val"
        done < $output_file

        # don't know what this is; found in sir's code
        enr_nj=$(echo "scale=2; $energy_efficiency*1000000000.0" | bc)


            # ==========================================================================
    # OUTPUT FILE GENERATION
    # ==========================================================================
    echo "######################################" >> $output_file2
    echo "# of Nodes:                   $nNodes " >> $output_file2
    echo "# of flows:                   $nFlows " >> $output_file2
    echo "Packet size:                  $pcktRate " >> $output_file2
    echo "Coverage                      $cover " >> $output_file2


    echo "" >> $output_file2

    echo "Throughput:                   $thr " >> $output_file2
    echo "AverageDelay:                 $del " >> $output_file2
    echo "Sent Packets:                 $s_packet " >> $output_file2
    echo "Received Packets:             $r_packet " >> $output_file2
    echo "Dropped Packets:              $d_packet " >> $output_file2
    echo "PacketDeliveryRatio:          $del_ratio " >> $output_file2
    echo "PacketDropRatio:              $dr_ratio " >> $output_file2
    echo "Total time:                   $time " >> $output_file2
    echo "Total energy consumption:     $t_energy " >> $output_file2
    echo "Average Energy per bit:       $energy_bit " >> $output_file2
    echo "Average Energy per byte:      $energy_byte " >> $output_file2
    echo "Average energy per packet:    $energy_packet " >> $output_file2
    echo "total_retransmit:             $total_retransmit " >> $output_file2
    echo "energy_efficiency(nj/bit):    $enr_nj " >> $output_file2
    echo "######################################" >> $output_file2
    echo "" >> $output_file2
    # ==========================================================================

    # ==========================================================================
    # GRAPH GENERATION
    # ==========================================================================
    echo -ne "$nFlows " >> $graphData      

    echo "$thr $del $del_ratio $dr_ratio $t_energy $energy_byte" >> $graphData


    truncate -s 0 $output_file

done

    arr[0]=""
    arr[1]="Throughput"
    arr[2]="Average Delay"
    arr[3]="Packet Delivery Ratio"
    arr[4]="Packet Drop Ratio"
    arr[5]="Total Energy consumption"
    arr[6]="Energy per byte"

    arr2[0]=""
    arr2[1]="Throughput ( bit/second )"
    arr2[2]="Average Delay ( second )"
    arr2[3]="Packet Delivery Ratio ( % )"
    arr2[4]="Packet Drop Ratio ( % )"
    arr2[5]="Total Energy consumption ( J )"
    arr2[6]="Energy per byte ( J )"

    for((i=1;i<7;i++))
    do
    gnuplot -persist -e "set title '802.11 : ${arr[$i]} vs Flows'; set xlabel 'Flows'; set ylabel '${arr2[$i]}'; plot 'out/GRAPH' using 1:$i+1 with lines"
    done
    truncate -s 0 $graphData




#vary packets
for((i=0;i<5;i++))
do


    nNodes=${nodes[4]}
    nFlows=${flow[4]}
    pcktRate=${packets[$i]}
    cover=${coverage[4]}

    l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
    dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;


    ns wireless_static_802_15_4.tcl $nNodes $nFlows $pcktRate $cover
    
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file

    while read val
        do

            l=$(($l+1))

            if [ "$l" == "1" ]; then
                thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
                #       echo -ne "throughput: $thr "
            elif [ "$l" == "2" ]; then
                del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
                #       echo -ne "delay: "
            elif [ "$l" == "3" ]; then
                s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
                #       echo -ne "send packet: "
            elif [ "$l" == "4" ]; then
                r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
                #       echo -ne "received packet: "
            elif [ "$l" == "5" ]; then
                d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
                #       echo -ne "drop packet: "
            elif [ "$l" == "6" ]; then
                del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
                #       echo -ne "delivery ratio: "
            elif [ "$l" == "7" ]; then
                dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
                #       echo -ne "drop ratio: "
            elif [ "$l" == "8" ]; then
                time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
                #       echo -ne "time: "
            elif [ "$l" == "9" ]; then
                t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
                #       echo -ne "total_energy: "
            elif [ "$l" == "10" ]; then
                energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_bit: "
            elif [ "$l" == "11" ]; then
                energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_byte: "
            elif [ "$l" == "12" ]; then
                energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_packet: "
            elif [ "$l" == "13" ]; then
                total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
                #       echo -ne "total_retrnsmit: "
            elif [ "$l" == "14" ]; then
                energy_efficiency=$(echo "scale=9; $energy_efficiency+$val/$iteration_float" | bc)
                #       echo -ne "energy_efficiency: "
            fi

            #echo "$val"
        done < $output_file

        # don't know what this is; found in sir's code
        enr_nj=$(echo "scale=2; $energy_efficiency*1000000000.0" | bc)


            # ==========================================================================
    # OUTPUT FILE GENERATION
    # ==========================================================================
    echo "######################################" >> $output_file2
    echo "# of Nodes:                   $nNodes " >> $output_file2
    echo "# of flows:                   $nFlows " >> $output_file2
    echo "Packet size:                  $pcktRate " >> $output_file2
    echo "Coverage                      $cover " >> $output_file2


    echo "" >> $output_file2

    echo "Throughput:                   $thr " >> $output_file2
    echo "AverageDelay:                 $del " >> $output_file2
    echo "Sent Packets:                 $s_packet " >> $output_file2
    echo "Received Packets:             $r_packet " >> $output_file2
    echo "Dropped Packets:              $d_packet " >> $output_file2
    echo "PacketDeliveryRatio:          $del_ratio " >> $output_file2
    echo "PacketDropRatio:              $dr_ratio " >> $output_file2
    echo "Total time:                   $time " >> $output_file2
    echo "Total energy consumption:     $t_energy " >> $output_file2
    echo "Average Energy per bit:       $energy_bit " >> $output_file2
    echo "Average Energy per byte:      $energy_byte " >> $output_file2
    echo "Average energy per packet:    $energy_packet " >> $output_file2
    echo "total_retransmit:             $total_retransmit " >> $output_file2
    echo "energy_efficiency(nj/bit):    $enr_nj " >> $output_file2
    echo "######################################" >> $output_file2
    echo "" >> $output_file2
    # ==========================================================================

    # ==========================================================================
    # GRAPH GENERATION
    # ==========================================================================
    echo -ne "$pcktRate " >> $graphData      

    echo "$thr $del $del_ratio $dr_ratio $t_energy $energy_byte" >> $graphData


    truncate -s 0 $output_file

done

    arr[0]=""
    arr[1]="Throughput"
    arr[2]="Average Delay"
    arr[3]="Packet Delivery Ratio"
    arr[4]="Packet Drop Ratio"
    arr[5]="Total Energy consumption"
    arr[6]="Energy per byte"

    arr2[0]=""
    arr2[1]="Throughput ( bit/second )"
    arr2[2]="Average Delay ( second )"
    arr2[3]="Packet Delivery Ratio ( % )"
    arr2[4]="Packet Drop Ratio ( % )"
    arr2[5]="Total Energy consumption ( J )"
    arr2[6]="Energy per byte ( J )"

    for((i=1;i<7;i++))
    do
    gnuplot -persist -e "set title '802.11 : ${arr[$i]} vs Packet Rate'; set xlabel 'Packet Rate'; set ylabel '${arr2[$i]}'; plot 'out/GRAPH' using 1:$i+1 with lines"
    done
    truncate -s 0 $graphData




#vary Coverage
for((i=0;i<5;i++))
do


    nNodes=${nodes[4]}
    nFlows=${flow[4]}
    pcktRate=${packets[4]}
    cover=${coverage[$i]}

    l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
    dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;


    ns wireless_static_802_15_4.tcl $nNodes $nFlows $pcktRate $cover
    
    awk -f wireless_static_802_15_4.awk wireless_static_802_15_4.tr >> $output_file

    while read val
        do

            l=$(($l+1))

            if [ "$l" == "1" ]; then
                thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
                #       echo -ne "throughput: $thr "
            elif [ "$l" == "2" ]; then
                del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
                #       echo -ne "delay: "
            elif [ "$l" == "3" ]; then
                s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
                #       echo -ne "send packet: "
            elif [ "$l" == "4" ]; then
                r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
                #       echo -ne "received packet: "
            elif [ "$l" == "5" ]; then
                d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
                #       echo -ne "drop packet: "
            elif [ "$l" == "6" ]; then
                del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
                #       echo -ne "delivery ratio: "
            elif [ "$l" == "7" ]; then
                dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
                #       echo -ne "drop ratio: "
            elif [ "$l" == "8" ]; then
                time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
                #       echo -ne "time: "
            elif [ "$l" == "9" ]; then
                t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
                #       echo -ne "total_energy: "
            elif [ "$l" == "10" ]; then
                energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_bit: "
            elif [ "$l" == "11" ]; then
                energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_byte: "
            elif [ "$l" == "12" ]; then
                energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
                #       echo -ne "energy_per_packet: "
            elif [ "$l" == "13" ]; then
                total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
                #       echo -ne "total_retrnsmit: "
            elif [ "$l" == "14" ]; then
                energy_efficiency=$(echo "scale=9; $energy_efficiency+$val/$iteration_float" | bc)
                #       echo -ne "energy_efficiency: "
            fi

            #echo "$val"
        done < $output_file

        # don't know what this is; found in sir's code
        enr_nj=$(echo "scale=2; $energy_efficiency*1000000000.0" | bc)


            # ==========================================================================
    # OUTPUT FILE GENERATION
    # ==========================================================================
    echo "######################################" >> $output_file2
    echo "# of Nodes:                   $nNodes " >> $output_file2
    echo "# of flows:                   $nFlows " >> $output_file2
    echo "Packet size:                  $pcktRate " >> $output_file2
    echo "Coverage                      $cover " >> $output_file2


    echo "" >> $output_file2

    echo "Throughput:                   $thr " >> $output_file2
    echo "AverageDelay:                 $del " >> $output_file2
    echo "Sent Packets:                 $s_packet " >> $output_file2
    echo "Received Packets:             $r_packet " >> $output_file2
    echo "Dropped Packets:              $d_packet " >> $output_file2
    echo "PacketDeliveryRatio:          $del_ratio " >> $output_file2
    echo "PacketDropRatio:              $dr_ratio " >> $output_file2
    echo "Total time:                   $time " >> $output_file2
    echo "Total energy consumption:     $t_energy " >> $output_file2
    echo "Average Energy per bit:       $energy_bit " >> $output_file2
    echo "Average Energy per byte:      $energy_byte " >> $output_file2
    echo "Average energy per packet:    $energy_packet " >> $output_file2
    echo "total_retransmit:             $total_retransmit " >> $output_file2
    echo "energy_efficiency(nj/bit):    $enr_nj " >> $output_file2
    echo "######################################" >> $output_file2
    echo "" >> $output_file2
    # ==========================================================================

    # ==========================================================================
    # GRAPH GENERATION
    # ==========================================================================
    echo -ne "$cover " >> $graphData      

    echo "$thr $del $del_ratio $dr_ratio $t_energy $energy_byte" >> $graphData


    truncate -s 0 $output_file

done

    arr[0]=""
    arr[1]="Throughput"
    arr[2]="Average Delay"
    arr[3]="Packet Delivery Ratio"
    arr[4]="Packet Drop Ratio"
    arr[5]="Total Energy consumption"
    arr[6]="Energy per byte"

    arr2[0]=""
    arr2[1]="Throughput ( bit/second )"
    arr2[2]="Average Delay ( second )"
    arr2[3]="Packet Delivery Ratio ( % )"
    arr2[4]="Packet Drop Ratio ( % )"
    arr2[5]="Total Energy consumption ( J )"
    arr2[6]="Energy per byte ( J )"

    for((i=1;i<7;i++))
    do
    gnuplot -persist -e "set title '802.11 : ${arr[$i]} vs Coverage'; set xlabel 'Coverage'; set ylabel '${arr2[$i]}'; plot 'out/GRAPH' using 1:$i+1 with lines"
    done
    truncate -s 0 $graphData