# making a star topology

#simulator object
set ns [new Simulator]

#files for animator and trace
set tr [open "out.tr" w]
$ns trace-all $tr

set anime [open "out.nam" w]
$ns namtrace-all $anime

proc finish { } {
    global ns tr anime
    $ns flush-trace     ;#clean buffer
    close $tr
    close $anime
    exec nam out.nam &
    exit 
}

#traffic color
$ns color 1 red
$ns color 2 blue


#5 nodes
set n0 [$ns node]
$n0 shape box
$n0 color red

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#make the graph
$ns duplex-link $n0 $n1 2Mb 3ms DropTail  
$ns duplex-link $n0 $n2 2Mb 3ms DropTail  
$ns duplex-link $n0 $n3 2Mb 3ms DropTail  
$ns duplex-link $n0 $n4 2Mb 3ms DropTail   

#------------------------------------------------
# TCP application for n1 and n2
set tcp0 [new Agent/TCP]
set sink [new Agent/TCPSink]

$ns attach-agent $n1 $tcp0
$ns attach-agent $n2 $sink

$ns connect $tcp0 $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp0

$tcp0 set fid_ 1
#------------------------------------------------


#------------------------------------------------
#CBR for n3 and n4
set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]

$ns attach-agent $n3 $tcp1
$ns attach-agent $n4 $sink1

$ns connect $tcp1 $sink1

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp1

$tcp1 set fid_ 2
#------------------------------------------------


#schedule of the simulator
$ns at .1 "$ftp start"
$ns at .2 "$cbr start"
$ns at 2 "$ftp stop"
$ns at 2 "$cbr stop"
$ns at 2.1 "finish"

$ns run