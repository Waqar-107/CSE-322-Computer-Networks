# making a star topology

#simulator object
set ns [new Simulator]

#files for animator and trace
set tr [open "out.tr" w]
$ns trace-all $tr

set anime [open "out.nam" w]
$ns namtrace-all-wireless $anime 100 100

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
set n5 [$ns node]
set n6 [$ns node]

$n4 set X_ 10.0
$n4 set Y_ 70.0

$n5 set X_ 30.0
$n5 set Y_ 60.0

$n6 set X_ 50.0
$n6 set Y_ 90.0

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