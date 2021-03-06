# 802.15.4
# wireless-static

#=========================================================================
# 1.set values of the parameters
#=========================================================================

#-------------------------
#network size
set x_dim 200
set y_dim 200
#-------------------------

#-------------------------
#number of nodes - num_row * num_col - grid representation
set tot_node [lindex $argv 0]
set num_row 10
set num_col [expr $tot_node/$num_row]	;#assuming the node quantity is always divisible by 10 in this assignment

set num_flow [lindex $argv 1]
set num_of_packet [lindex $argv 2]
set coverage_area [lindex $argv 3]
#-------------------------

#-------------------------
#number and other attributes of flows
set time_duration 25
set start_time 5
set random_flow_start_gap 0.1
set extra_time 0
#-------------------------

#-------------------------
set cbr_size 28
set cbr_rate $num_of_packet
set cbr_interval 1
set cbr_type CBR
#-------------------------

#-----------------------------------------------------------------------------------
#energy parameters
set val(energymodel_15_4)			EnergyModel      ;
set val(initialenergy_15_4)			100              ;# Initial energy in Joules
set val(idlepower_15_4)     		712e-6			  
set val(rxpower_15_4) 				35.28e-3			 
set val(txpower_15_4) 				31.32e-3			  
set val(sleeppower_15_4) 			144e-9			  
#set val(transitionpower_15_4) 		200e-3		      
#set val(transitiontime_15_4) 		3			      
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
#protocols and models for different layers
set val(chan) 		Channel/WirelessChannel      ;# channel type
set val(prop) 		Propagation/TwoRayGround     ;# radio-propagation model
set val(netif) 		Phy/WirelessPhy/802_15_4     ;# network interface type
set val(mac) 		Mac/802_15_4		 		 ;# MAC type
set val(ifq) 		Queue/DropTail/PriQueue      ;# interface queue type
set val(ll) 		LL                           ;# link layer type
set val(ant) 		Antenna/OmniAntenna          ;# antenna model
set val(ifqlen) 	100                          ;# max packet in ifq
set val(rp) 		AODV                         ;# routing protocol - Ad Hoc On-Demand Distance Vector
#------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------
#transmission range
set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07

set dist(150m) 2.81838e-09
set dist(175m) 1.52129e-09
set dist(200m) 8.91754e-10
set dist(225m) 5.56717e-10
set dist(250m) 3.65262e-10
set dist(500m) 2.28289e-11
set dist(1000m) 1.42681e-12

set default_coverage $dist(200m) 
if {$coverage_area == 2} {
	set default_coverage $dist(225m)
}
if {$coverage_area == 3} {
	set default_coverage $dist(250m)
}
if {$coverage_area == 4} {
	set default_coverage $dist(500m)
}
if {$coverage_area == 5} {
	set default_coverage $dist(1000m)
}

Phy/WirelessPhy set CSThresh_ $default_coverage
Phy/WirelessPhy set RXThresh_ $default_coverage
#------------------------------------------------------------------------------------

#=========================================================================
# 2.Initialize ns
set ns [new Simulator]
#=========================================================================



#=========================================================================
# 3.Open files
#=========================================================================

#log-file
set tracefile [open wireless_static_802_15_4.tr w]
$ns trace-all $tracefile

#animation file
set namfile [open wireless_static_802_15_4.nam w]
$ns namtrace-all-wireless $namfile $x_dim $y_dim

#report will be generated using this
set topofile [open wireless_static_802_15_4.txt w]

set topo [new Topography]
$topo load_flatgrid $x_dim $y_dim	             ;#flatgrid for (x,y) -> 2D

create-god [expr $num_row * $num_col]



#=========================================================================
# 4. Node configuration
#=========================================================================

# configure the nodes - make sure not to give anything ecept '\n' in front of '\'
$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-channel [new $val(chan)] \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace OFF\
		-macTrace ON \
		-movementTrace OFF \
		-energyModel $val(energymodel_15_4) \
		-idlePower $val(idlepower_15_4) \
		-rxPower $val(rxpower_15_4) \
		-txPower $val(txpower_15_4) \
        -sleepPower $val(sleeppower_15_4) \
		-initialEnergy $val(initialenergy_15_4)



#=========================================================================
# 5.Create nodes with positioning
#=========================================================================
puts "start node creation"

for {set i 0} {$i < [expr $num_col*$num_row]} {incr i} {
	set node_($i) [$ns node]
	$node_($i) random-motion 0					 ;#random-motion 0 is to make static
}

#node position in the animation
set x_start [expr $x_dim/($num_col*2)]
set y_start [expr $y_dim/($num_row*2)]

set i 0
while {$i < $num_row} {
	for {set j 0} {$j < $num_col} {incr j} {

		# number of a node, starting from 
		set m [expr $i * $num_col + $j]
		
		# coord of the node
		set x_pos [expr $x_start + $j * ($x_dim/$num_col)]
		set y_pos [expr $y_start + $i * ($y_dim/$num_row)]

		$node_($m) set X_ $x_pos
		$node_($m) set Y_ $y_pos
		$node_($m) set Z_ 0.0

		puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
	}

	incr i
}


puts "finished node creation\n"



#=========================================================================
# 6.Create flows and associate them with nodes
# attach transport layer agents e.g- TCP, UDP; attach traffic e.g- ftp, cbr
# specify flow, src-sink in transport layer
# this is actually building the topology or we can say making the graph
#=========================================================================

#random flow
set nn [expr $num_col*$num_row]

#made udp and null for each node, some will remain unused
for {set i 0} {$i < $num_flow} {incr i} {
	
	set udp_($i) [new Agent/UDP]
	$udp_($i) set class_ $i
	$udp_($i) set fid_ $i

	set null_($i) [new Agent/Null]
	
	#color of traffic
	if { [expr $i%2] == 0 } {
		$ns color $i Blue
	} else {
		$ns color $i Red
	}
} 

# determine src-sink
set rt 0
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_node [expr int($nn*rand()) % $nn ] 		  		;# src node
	set null_node $udp_node

	while {$null_node == $udp_node} {
		set null_node [expr int($nn*rand()) % $nn] 	;# dest node
	}

	#puts "src: $udp_node  sink: $null_node\n"

	$ns attach-agent $node_($udp_node) $udp_($rt)
  	$ns attach-agent $node_($null_node) $null_($rt)
	
	incr rt
	puts -nonewline $topofile "flow of nodes: Src: $udp_node Dest: $null_node\n"
} 

#connect src-dest
set rt 0
for {set i 0} {$i < $num_flow} {incr i} {
     $ns connect $udp_($rt) $null_($rt)
	 incr rt
}

#attach cbr
for {set i 0} {$i < $num_flow} {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	
	$cbr_($i) set type_ $cbr_type
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	
	$cbr_($i) attach-agent $udp_($i)
} 

for {set i 0} {$i < $num_flow } {incr i} {
     $ns at [expr $start_time + $i * $random_flow_start_gap] "$cbr_($i) start"
}

puts "flow creation complete"



#=========================================================================
# 7.Set timings of different events
#=========================================================================
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns at [expr $start_time+$time_duration] "$node_($i) reset";
}

$ns at [expr $start_time + $time_duration + $extra_time] "finish"
$ns at [expr $start_time + $time_duration + $extra_time] "$ns nam-end-wireless [$ns now]; puts \"NS Exiting...\"; $ns halt"

$ns at [expr $start_time + $time_duration/2] "puts \"half of the simulation is finished\""
$ns at [expr $start_time + $time_duration] "puts \"end of simulation duration\""



#=========================================================================
# 8.Write tasks to do after finishing the simulation in a procedure named finish
#=========================================================================
proc finish {} {
	puts "finishing"
	global ns tracefile topofile namfile 
	$ns flush-trace
	close $tracefile
	close $namfile
	close $topofile
    exit 0
}


500m
#======================500m===================================================
# 9.Run the simulation500m
#======================500m===================================================
# define nodes initiall500my - 10 is the size of the node
for {set i 0} {$i < [ex500mpr $num_row*$num_col]  } { incr i} {
	$ns initial_node_po500ms $node_($i) 10
}

puts "running the simulation"
$ns run

#Invalid PSDU/MPDU length:
#in p802_15_4phy.cc, if psdulength > aMaxPHYPktSize this error occurs. max size of pkt in 802.15.4 is 127
# "$cbr_($i) set type_ $cbr_type" helped to get rid of the error
#https://www.mail-archive.com/ns-users@isi.edu/msg01629.html