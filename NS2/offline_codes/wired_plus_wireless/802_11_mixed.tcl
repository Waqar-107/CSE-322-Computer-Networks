# 802.11
# wired + wireless static + wireless mobile

#=========================================================================
# 1.set values of the parameters
#=========================================================================

#-------------------------
#network size
set x_dim 100
set y_dim 100
#-------------------------

#-------------------------
set total_node 7

set num_of_packet [lindex $argv 0]
set node_speed [lindex $argv 1]
#-------------------------

#-------------------------
#number and other attributes of flows
set time_duration 20
set start_time .1
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
set val(mac) 		Mac/802_11                   ;# MAC type
set val(ifq) 		Queue/DropTail/PriQueue      ;# interface queue type
set val(ll) 		LL                           ;# link layer type
set val(ant) 		Antenna/OmniAntenna          ;# antenna model
set val(ifqlen) 	50                           ;# max packet in ifq - 50 is optimal
set val(rp) 		DSDV                         ;# routing protocol
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

set dist(150) 2.81838e-09
set dist(175) 1.52129e-09
set dist(200) 8.91754e-10
set dist(225) 5.56717e-10
set dist(250m) 3.65262e-10
set dist(500m) 2.28289e-11
set dist(1000m) 1.42681e-12

Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)
#------------------------------------------------------------------------------------

#=========================================================================
# 2.Initialize ns
#=========================================================================

set ns [new Simulator]

#-------------------------
#traffic color
$ns color 1 red
$ns color 2 blue
$ns color 3 green
#-------------------------



#=========================================================================
# 3.Open files
#=========================================================================

#log-file
set tracefile [open 802_11_mixed.tr w]
$ns trace-all $tracefile

$ns use-newtrace

#animation file
set namfile [open 802_11_mixed.nam w]
$ns namtrace-all-wireless $namfile $x_dim $y_dim

#report will be generated using this
set topofile [open 802_11_mixed.txt w]

set topo [new Topography]
$topo load_flatgrid $x_dim $y_dim	             ;#flatgrid for (x,y) -> 2D

create-god $total_node

#=========================================================================
# 5.Create nodes with positioning
#=========================================================================
puts "start node creation"

#4 nodes are wired, 3 are wireless. among the wireless, 2 are mobile and 1 is static
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#declaring some extra agents and traffic
for {set i 0} {$i < 50} {incr i} {
    set tcp_($i) [new Agent/TCP]
    set sink_($i) [new Agent/TCPSink]
    set ftp_($i) [new Application/FTP]

    $ftp_($i) attach-agent $tcp_($i)
}

#-------------------------------------------------------------------------
# 4. Node configuration
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
        -wiredRouting ON \
		-energyModel $val(energymodel_11) \
		-idlePower $val(idlepower_11) \
		-rxPower $val(rxpower_11) \
		-txPower $val(txpower_11) \
        -sleepPower $val(sleeppower_11) \
        -transitionPower $val(transitionpower_11) \
		-transitionTime $val(transitiontime_11) \
		-initialEnergy $val(initialenergy_11)
#-------------------------------------------------------------------------
set n4 [$ns node]
$n4 set X_ 40.0
$n4 set Y_ 40.0

set n5 [$ns node]
$n5 set X_ 90.0
$n5 set Y_ 40.0

set n6 [$ns node]
$n6 set X_ 60.0
$n6 set Y_ 80.0

#=========================================================================
# 6.Create flows and associate them with nodes
# attach transport layer agents e.g- TCP, UDP; attach traffic e.g- ftp, cbr
# specify flow, src-sink in transport layer
# this is actually building the topology or we can say making the graph
#=========================================================================

#wired
$ns duplex-link $n0 $n1 2Mb 3ms DropTail  
$ns duplex-link-op $n0 $n1 orient left-down

$ns duplex-link $n1 $n2 2Mb 3ms DropTail 
$ns duplex-link $n2 $n3 2Mb 3ms DropTail

$ns duplex-link $n0 $n2 2Mb 3ms DropTail
$ns duplex-link-op $n0 $n2 orient right-down

#wired connection
$ns attach-agent $n0 $tcp_(0)
$ns attach-agent $n1 $sink_(0)
$ns connect $tcp_(0) $sink_(0)

$ns attach-agent $n0 $tcp_(1)
$ns attach-agent $n2 $sink_(1)
$ns connect $tcp_(1) $sink_(1)

$ns attach-agent $n1 $tcp_(2)
$ns attach-agent $n2 $sink_(2)
$ns connect $tcp_(2) $sink_(2)

$ns attach-agent $n2 $tcp_(3)
$ns attach-agent $n3 $sink_(3)
$ns connect $tcp_(3) $sink_(3)

#packet color
$tcp_(0) set fid_ 1
$tcp_(1) set fid_ 2
$tcp_(2) set fid_ 3
$tcp_(3) set fid_ 1

#wireless

$ns attach-agent $n4 $tcp_(4)
$ns attach-agent $n5 $sink_(4)
$ns connect $tcp_(4) $sink_(4)

$ns attach-agent $n6 $tcp_(5)
$ns attach-agent $n0 $sink_(5)
$ns connect $tcp_(5) $sink_(5)

#-------------------------------------------
#mobility - params are:
#at what time? which node? where to? what speed? 
$ns at .3 "$n5 setdest [expr $x_dim*rand()] [expr $y_dim*rand()] $node_speed"
$ns at .3 "$n6 setdest [expr $x_dim*rand()] [expr $y_dim*rand()] $node_speed"
#-------------------------------------------

puts "flow creation complete"



#=========================================================================
# 7.Set timings of different events
#=========================================================================

$ns at .1 "$ftp_(0) start"
$ns at .1 "$ftp_(1) start"
$ns at .1 "$ftp_(2) start"
$ns at .1 "$ftp_(3) start"
$ns at .1 "$ftp_(4) start"
$ns at .1 "$ftp_(5) start"
$ns at [expr $start_time + $time_duration] "finish"



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

puts "running the simulation"
$ns run