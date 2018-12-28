=====================================================================
# TCL
=====================================================================

=======================
# energy model
=======================
1.by default nodes have inf energy, to make them finite we define enrgy models and power parameters
EnergyModel is a class in the .cc file we use
* set val(energymodel_ll) EnergyModel

- there are various energy models for different topology, and then "EnergyModel" keyword is used


2. initial power of a node
* set val(initialenergy_11)  val


3. idlepower is the power consumption when a node is idle
* set val(idlepower_11) val


4. rx and tx is the power consumed for receive and transmit 
* set val(rxpower_11) val
* set val(txpower_11) val


5. power consumed while sleeping
* set val(sleeppower_11) val


6. power consumed to wake-up from sleep 
*set val(transitionpower_11) val


7. time required to get-up
* set val(transitiontime_11) val

# agents
there are agents that will be attached with node variable
* set var_nam Agent/TCP
* set var_nam Agent/TCPSink
 
the graph is made using the nodes
$ns duplex-link $u $v 2Mb 3ms DropTail
the format is->
simulator-obj connection-type node1 node2 speed delay queue-type

# position of nodes
$node_name set X_ $pos
$node_name set Y_ $pos
$node_name set Z_ $pos


