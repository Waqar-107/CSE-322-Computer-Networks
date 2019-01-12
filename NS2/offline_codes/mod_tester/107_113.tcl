# 802.11
# wired network - to test mods in ns2.35

#=========================================================================
# 1.set values of the parameters
#=========================================================================

#-------------------------
#network size
set x_dim 100
set y_dim 100
#-------------------------

#-------------------------
set wired_node 7
set total_node $wired_node
#-------------------------

#-------------------------
#number and other attributes of flows
set time_duration 20
set start_time .1
#-------------------------

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
set tracefile [open 107_113.tr w]
$ns trace-all $tracefile

#animation file
set namfile [open 107_113.nam w]
$ns namtrace-all $namfile

set topo [new Topography]
$topo load_flatgrid $x_dim $y_dim	             ;#flatgrid for (x,y) -> 2D

#base+wireless
create-god $total_node

#=========================================================================
# 5.Create nodes with positioning
#=========================================================================
puts "start node creation"

#7 nodes are wired
for {set i 0} {$i < $wired_node} {incr i} {
	set n$i [$ns node]
}


for {set i 0} {$i < 1} {incr i} {
    set tcp_($i) [new Agent/TCP]
    set sink_($i) [new Agent/TCPSink]
    set ftp_($i) [new Application/FTP]

    $ftp_($i) attach-agent $tcp_($i)
}


#=========================================================================
# 6.Create flows and associate them with nodes
# attach transport layer agents e.g- TCP, UDP; attach traffic e.g- ftp, cbr
# specify flow, src-sink in transport layer
# this is actually building the topology or we can say making the graph
#=========================================================================

#wired
$ns duplex-link $n0 $n1 2Mb 3ms DropTail  
$ns duplex-link-op $n0 $n1 orient 45deg

$ns duplex-link $n0 $n2 2Mb 3ms DropTail
$ns duplex-link-op $n0 $n2 orient 315deg

$ns duplex-link $n1 $n3 2Mb 3ms DropTail 
$ns duplex-link-op $n1 $n3 orient 0deg

$ns duplex-link $n1 $n4 2Mb 3ms DropTail
$ns duplex-link-op $n1 $n4 orient 315deg

$ns duplex-link $n2 $n4 2Mb 3ms DropTail
$ns duplex-link-op $n2 $n4 orient 0deg

$ns duplex-link $n3 $n4 2Mb 3ms DropTail
$ns duplex-link-op $n3 $n4 orient 225deg

$ns duplex-link $n3 $n6 2Mb 3ms DropTail  
$ns duplex-link-op $n3 $n6 orient 315deg

$ns duplex-link $n4 $n5 2Mb 3ms DropTail
$ns duplex-link-op $n4 $n5 orient 0deg

$ns duplex-link $n5 $n6 2Mb 3ms DropTail 
$ns duplex-link-op $n5 $n6 orient 45deg

#wired connection
$ns attach-agent $n0 $tcp_(0)
$ns attach-agent $n6 $sink_(0)

#start from a node that is in wired part
#the destination is one that is wireless
$ns connect $tcp_(0) $sink_(0)

#-------------------------------------------

puts "flow creation complete"

$tcp_(0) set fid_ 1

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