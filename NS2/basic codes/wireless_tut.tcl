# example of wireless networks
# step-1  :  init variables
# step-2  :  create a simulator object
# step-3  :  create tracing and animation file
# step-4  :  topography
# step-5  :  GOD - General Operations Director
# step-6  :  create channel(communication path)
# step-7  :  create nodes
# step-8  :  position of the nodes (wireless nodes needs a location)
# step-9  :  any mobilty codes (if nodes are moving)
# step-10 :  agent creation - TCP, UDP. Traffic-> ftp, cbr


#================================================
# intialize the variables
# here val is an array, you can name it anything
# the 3rd part here(e.g Channel/WirelessChannel) is c++ files

set val(chan)   Channel/WirelessChannel      ;# channel type
set val(prop)   Propagation/TwoRayGround     ;# radio-propagation model
set val(netif)  Phy/WirelessPhy              ;# network interface type
set val(mac)    Mac/802_11                   ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue      ;# interface queue type
set val(ll)     LL                           ;# link layer type
set val(ant)    Antenna/OmniAntenna          ;# antenna model
set val(ifqlen) 50                           ;# max packet in ifq -50 is optimal
set val(rp)     AODV                         ;# routing protocol - Adhoc OnDemand Distance Vector
set val(nn)     6			     ;# node quantity     
set val(x) 	1000			     ;# x dimension
set val(y) 	1000			     ;# y dimension

# energy parameters - not in the tutorial - taken from raji sir
set val(energymodel_11)         EnergyModel  ;# it is a c++ class
set val(initialenergy_11)  	1000         ;# Initial energy in Joules
set val(idlepower_11) 		900e-3	     ;#Stargate (802.11b) 
set val(rxpower_11) 		925e-3	     ;#Stargate (802.11b)
set val(txpower_11) 		1425e-3	     ;#Stargate (802.11b)
set val(sleeppower_11) 		300e-3	     ;#Stargate (802.11b)
set val(transitionpower_11) 	200e-3	     ;#Stargate (802.11b)
set val(transitiontime_11) 	3	     ;#Stargate (802.11b)
#================================================


#================================================
# create a simulator object
set ns [new Simulator]
#================================================


#================================================
# create tracing and animation file
# tracefile is like a log, nam is the anime
set tracefile [open wireless_tut.tr w]
$ns trace-all $tracefile

set namfile [open wireless_tut.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)
#================================================


#================================================
# create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)	;#flatgrid for (x,y) -> 2D
#================================================


#================================================
# create GOD - General Operations Director
# control things like packet exchange, not mandatory
create-god $val(nn)	;# create-god "node quantity"
#================================================


#================================================
# create channel
set channel1 [new $val(chan)]
#================================================


#================================================
# configure the nodes - make sure not to give anything ecept '\n' in front of '\'
$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-channel $channel1 \
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
#================================================


#================================================
# node creation

# some node declaration
# $ns node-config -channel $channel2
# some node declaration
# in the above way we can make different config for routers

for {set i 0} {$i < $val(nn)} {incr i} {	
	set node_($i) [$ns node];
	$node_($i) random-motion 0;#when they move, do not move randomly

}

#set coord of the nodes
for {set i 0} {$i < $val(nn)} {incr i} {
	$node_($i) set X_ [expr 100+$i*20]
	$node_($i) set Y_ [expr 100+100*($i%2)]
#	$node_($i) set Z_ 0.0
#}

#================================================
#================================================
# mobility of nodes
# at what time? which node? where to? at what speed?
$ns at 1.0 "$node_(1) setdest 490.0 340.0 25.0"
$ns at 1.0 "$node_(4) setdest 300.0 130.0 5.0"
$ns at 1.0 "$node_(5) setdest 190.0 440.0 15.0"

#the nodes can move any number of times at any location during simulation
#================================================
#================================================
# create agents
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]

$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(5) $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 1.0 "$ftp start"


set udp [new Agent/UDP]
set null [new Agent/Null]

$ns attach-agent $node_(2) $udp
$ns attach-agent $node_(3) $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns at 1.0 "$cbr start"
#================================================

#================================================
# finish procedure
proc finish {} {
	puts "finishing"
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefile
	close $namfile
	exec nam wireless_tut.nam &
        exit 0
}

$ns at 10.0 "finish"
#================================================

puts "Starting Simulation"
$ns run
