#creating ns simulator object
set ns [new Simulator]

#open file to save simulation
set tr [ open "out.tr" w]
$ns trace-all $tr

#open a file for the animator
set anime [ open "out.nam" w]
$ns namtrace-all $anime

#create nodes - just like decalring variables
set n0 [$ns node]
set n1 [$ns node]

#set color and shape of nodes
$n0 shape box
$n0 color green

#establish a connection - simulator_var_name connection_type u v speed delay queue
#Drop Tail: It is a simple queue mechanism that is used by the routers that when packets
#should to be drop. In this mechanism each packet is treated identically and when queue
#filled to its maximum capacity the newly incoming packets are dropped until queue have
#sufficient space to accept incoming traffic.

$ns duplex-link $n0 $n1 2Mb 4ms DropTail

set tcp1 [new Agent/TCP]
set sink [new Agent/TCPSink]

#attach the agents to nodes
$ns attach-agent $n0 $tcp1
$ns attach-agent $n1 $sink

#establish connection - always between two agents, not two nodes
$ns connect $tcp1 $sink

#application layer
set ftp [new Application/FTP]
$ftp attach-agent $tcp1

#tasks to do after we are done
proc finish {} {
    global ns tr anime
    $ns flush-trace     ;#clean buffer
    close $tr
    close $anime
    exec nam out.nam &  ;#see the animation 
    exit
}

$ns at .1 "$ftp start"
$ns at 2.0 "$ftp stop"

$ns at 2.1 "finish"

$ns run
