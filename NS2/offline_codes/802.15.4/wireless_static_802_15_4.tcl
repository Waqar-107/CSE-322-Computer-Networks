# 802.15.4
# wireless-static

#=========================================================================
# 1.set values of the parameters
#=========================================================================

#-------------------------
#network size
set x_dim 1000
set y_dim 1000
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
set time_duration 5
set start_time 1
set parallel_start_gap 1.0
set extra_time 10
#-------------------------

#-------------------------
set cbr_size 1000
set cbr_rate $num_of_packet
set cbr_interval 1
#-------------------------

#-----------------------------------------------------------------------------------
#energy parameters
set val(energymodel_15_4)			EnergyModel      ;
set val(initialenergy_15_4)			1000             ;# Initial energy in Joules
set val(idlepower_15_4)     		900e-3			 ;#Stargate (802.15.4b) 
set val(rxpower_15_4) 				925e-3			 ;#Stargate (802.15.4b)
set val(txpower_15_4) 				1425e-3			 ;#Stargate (802.15.4b)
set val(sleeppower_15_4) 			300e-3			 ;#Stargate (802.15.4b)
set val(transitionpower_15_4) 		200e-3		     ;#Stargate (802.15.4b)
set val(transitiontime_15_4) 		3			     ;#Stargate (802.15.4b)
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
set val(ifqlen) 	50                           ;# max packet in ifq - 50 is optimal
set val(rp) 		DSDV                         ;# routing protocol
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
        -transitionPower $val(transitionpower_15_4) \
		-transitionTime $val(transitiontime_15_4) \
		-initialEnergy $val(initialenergy_15_4)



#=========================================================================
# 5.Create nodes with positioning
#=========================================================================
puts "start node creation"

for {set i 0} {$i < [expr $num_col*$num_row]} {incr i} {
	set node_($i) [$ns node]
	#$node_($i) random-motion 0					 ;#random-motion 0 is to make static
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

# there can be atmost total_node/2 flows
set nn [expr $num_col*$num_row]
if {$num_flow > [expr $nn/2]} {
	set num_flow [expr $nn/2]
}

for {set i 0} {$i < $nn} {incr i} {
	
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
set j [expr $nn - 1]
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_node $i
	set null_node $j
	puts "src: $i  sink: $j\n"
	$ns attach-agent $node_($udp_node) $udp_($i)
  	$ns attach-agent $node_($null_node) $null_($j)
	
	set j [expr $j-1]
	puts -nonewline $topofile "flow of nodes: Src: $udp_node Dest: $null_node\n"
} 

#connect src-dest
set j [expr $nn - 1]
for {set i 0} {$i < $num_flow} {incr i} {
     $ns connect $udp_($i) $null_($j)
	 set j [expr $j-1]
}

#attach cbr
for {set i 0} {$i < $num_flow} {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	
	$cbr_($i) attach-agent $udp_($i)
} 

for {set i 0} {$i < $num_flow } {incr i} {
     $ns at $start_time "$cbr_($i) start"
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



#=========================================================================
# 9.Run the simulation
#=========================================================================
# define nodes initially - 10 is the size of the node
for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 10
}

puts "running the simulation"
$ns run