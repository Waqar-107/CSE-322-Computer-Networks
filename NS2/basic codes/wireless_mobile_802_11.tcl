# 802.11
# wireless-mobile

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
set num_row 10
set num_col 5
#-------------------------

#-------------------------
#number and other attributes of flows
set time_duration 10
set start_time 1
set parallel_start_gap 1.0
set extra_time 10
#-------------------------

#-------------------------
set cbr_size 1000
set cbr_rate 11.0Mb
set cbr_interval 1
#-------------------------

#-----------------------------------------------------------------------------------
#energy parameters
set val(energymodel_11)			EnergyModel      ;
set val(initialenergy_11)		1000             ;# Initial energy in Joules
set val(idlepower_11)     		900e-3			 ;#Stargate (802.11b) 
set val(rxpower_11) 			925e-3			 ;#Stargate (802.11b)
set val(txpower_11) 			1425e-3			 ;#Stargate (802.11b)
set val(sleeppower_11) 			300e-3			 ;#Stargate (802.11b)
set val(transitionpower_11) 	200e-3		     ;#Stargate (802.11b)
set val(transitiontime_11) 		3			     ;#Stargate (802.11b)
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
#protocols and models for different layers
set val(chan) 		Channel/WirelessChannel      ;# channel type
set val(prop) 		Propagation/TwoRayGround     ;# radio-propagation model
set val(netif) 		Phy/WirelessPhy              ;# network interface type
set val(mac) 		Mac/802_15_4                   ;# MAC type
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
set tracefile [open wireless_mobile_802_11.tr w]
$ns trace-all $tracefile

#animation file
set namfile [open wireless_mobile_802_11.nam w]
$ns namtrace-all-wireless $namfile $x_dim $y_dim

#report will be generated using this
set topofile [open wireless_mobile_802_11.txt w]

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
		-energyModel $val(energymodel_11) \
		-idlePower $val(idlepower_11) \
		-rxPower $val(rxpower_11) \
		-txPower $val(txpower_11) \
        -sleepPower $val(sleeppower_11) \
        -transitionPower $val(transitionpower_11) \
		-transitionTime $val(transitiontime_11) \
		-initialEnergy $val(initialenergy_11)



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

#-------------------------------------------
#mobility - params are:
#at what time? which node? where to? what speed? 
set i 0
while {$i < [expr $num_row*$num_col]} {
    $ns at 2 "$node_($i) setdest [expr $x_dim*rand()] [expr $y_dim*rand()] 5"
    incr i 
}
#-------------------------------------------

#=========================================================================
# 6.Create flows and associate them with nodes
# attach transport layer agents e.g- TCP, UDP; attach traffic e.g- ftp, cbr
# specify flow, src-sink in transport layer
# this is actually building the topology or we can say making the graph
#=========================================================================

set nn [expr $num_col*$num_row]
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
for {set i 0} {$i < [expr $nn/2] } {incr i} {
	set udp_node $i
	set null_node $j
	puts "src: $i  sink: $j\n"
	$ns attach-agent $node_($udp_node) $udp_($i)
  	$ns attach-agent $node_($null_node) $null_($j)
	
	set j [expr $j-1]
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 

#connect src-dest
set j [expr $nn - 1]
for {set i 0} {$i < [expr $nn/2] } {incr i} {
     $ns connect $udp_($i) $null_($j)
	 set j [expr $j-1]
}

#attach cbr
for {set i 0} {$i < [expr $nn/2] } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	
	$cbr_($i) attach-agent $udp_($i)
} 

for {set i 0} {$i < [expr $nn/2] } {incr i} {
     $ns at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
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
    exec nam wireless_mobile_802_11.nam &
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