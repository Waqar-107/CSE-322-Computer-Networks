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
set total_node 2

set num_of_packet [lindex $argv 0]
set node_speed [lindex $argv 1]
#-------------------------

#-------------------------
#number and other attributes of flows
set time_duration 20
set start_time .1
#-------------------------

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


#=========================================================================
# 2.Initialize ns
#=========================================================================

set ns [new Simulator]

#wireless and wired should be in diff. domains
#in order to do so we use hierarchical topology structure
#configuring hierarchical topology structure
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2				;#number of domains
lappend cluster_num 2 1						;#number of cluster in each of the domains

AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 2					;#number of nodes in each cluster
AddrParams set nodes_num_ $eilastlevel		;#for each domain

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

#animation file
set namfile [open 802_11_mixed.nam w]
$ns namtrace-all-wireless $namfile $x_dim $y_dim

set topo [new Topography]
$topo load_flatgrid $x_dim $y_dim	             ;#flatgrid for (x,y) -> 2D

#base+wireless
create-god 2

#=========================================================================
# 5.Create nodes with positioning
#=========================================================================
puts "start node creation"

set temp {0.0.0 0.1.0}           ;# hierarchical addresses to be used

#4 nodes are wired, 1 is wireless static, 1 base-station
set n0 [$ns node [lindex $temp 0]]
set n1 [$ns node [lindex $temp 1]]

#declaring some extra agents and traffic
for {set i 0} {$i < 50} {incr i} {
    set tcp_($i) [new Agent/TCP]
    set sink_($i) [new Agent/TCPSink]
    set ftp_($i) [new Application/FTP]

    $ftp_($i) attach-agent $tcp_($i)
}

#-------------------------------------------------------------------------
# 4. Node configuration
#config for base station
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
        -wiredRouting ON
#-------------------------------------------------------------------------

set temp {1.0.0 1.0.1}   ;# hier address to be used for
                         ;# wireless domain

set bStation [$ns node [lindex $temp 0]]
$bStation set X_ 30.0
$bStation set Y_ 30.0
$bStation random-motion 0
$bStation color red

#change the config a bit
$ns node-config -wiredRouting OFF

set n4 [$ns node [lindex $temp 1]]
$n4 set X_ 50.0
$n4 set Y_ 40.0
$n4 random-motion 0
$n4 base-station [AddrParams addr2id [$bStation node-addr]]


#=========================================================================
# 6.Create flows and associate them with nodes
# attach transport layer agents e.g- TCP, UDP; attach traffic e.g- ftp, cbr
# specify flow, src-sink in transport layer
# this is actually building the topology or we can say making the graph
#=========================================================================

#wired
$ns duplex-link $n0 $n1 2Mb 3ms DropTail  
$ns duplex-link-op $n0 $n1 orient left-down

#$ns duplex-link $n1 $n2 2Mb 3ms DropTail 
#$ns duplex-link $n2 $n3 2Mb 3ms DropTail

#$ns duplex-link $n0 $n2 2Mb 3ms DropTail
#$ns duplex-link-op $n0 $n2 orient right-down

#connect nodes with base station
$ns duplex-link $n1 $bStation 5Mb 2ms DropTail

#wired connection
$ns attach-agent $n0 $tcp_(0)
$ns attach-agent $n4 $sink_(0)

#wireless
#$ns attach-agent $n4 $sink_(0)

#start from a node that is in wired part
#the destination is one that is wireless
$ns connect $tcp_(0) $sink_(0)

#-------------------------------------------
#mobility - params are:
#at what time? which node? where to? what speed? 
#$ns at .3 "$n5 setdest [expr $x_dim*rand()] [expr $y_dim*rand()] $node_speed"
#$ns at .3 "$n6 setdest [expr $x_dim*rand()] [expr $y_dim*rand()] $node_speed"
#-------------------------------------------

puts "flow creation complete"

#init pos of wireless node
$ns initial_node_pos $n4 20

#=========================================================================
# 7.Set timings of different events
#=========================================================================

$ns at .1 "$ftp_(0) start"
$ns at [expr $start_time + $time_duration] "finish"



#=========================================================================
# 8.Write tasks to do after finishing the simulation in a procedure named finish
#=========================================================================
proc finish {} {
	puts "finishing"
	global ns tracefile namfile 
	$ns flush-trace
	close $tracefile
	close $namfile
    exit 0
}



#=========================================================================
# 9.Run the simulation
#=========================================================================

puts "running the simulation"
$ns run