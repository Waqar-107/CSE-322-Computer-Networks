#=========================================================================
# set values of the parameters
#=========================================================================

#-------------------------
#network size
set x_dimension 1000
set y_dimension 1000
#-------------------------

#-------------------------
#number of nodes - num_row * num_col
set num_row 10
set num_col 5
#-------------------------

#-------------------------
#number and other attributes of flows
set time_duration 60
set start_time 10
set parallel_start_gap 1.0
#-------------------------

#-------------------------
set cbr_size 1000
set cbr_rate 11.0Mb
set cbr_interval 1
#-------------------------

#-----------------------------------------------------------------------------------
#energy parameters
set val(energymodel_11)    EnergyModel      ;
set val(initialenergy_11)  1000             ;# Initial energy in Joules
set val(idlepower_11) 900e-3			    ;#Stargate (802.11b) 
set val(rxpower_11) 925e-3			        ;#Stargate (802.11b)
set val(txpower_11) 1425e-3			        ;#Stargate (802.11b)
set val(sleeppower_11) 300e-3			    ;#Stargate (802.11b)
set val(transitionpower_11) 200e-3		    ;#Stargate (802.11b)
set val(transitiontime_11) 3			    ;#Stargate (802.11b)
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
#protocols and models for different layers
set val(chan) Channel/WirelessChannel                   ;# channel type
set val(prop) Propagation/TwoRayGround                  ;# radio-propagation model
#set val(prop) Propagation/FreeSpace                    ;# radio-propagation model
set val(netif) Phy/WirelessPhy                          ;# network interface type
set val(mac) Mac/802_11                                 ;# MAC type
#set val(mac) SMac/802_15_4                             ;# MAC type
set val(ifq) Queue/DropTail/PriQueue                    ;# interface queue type
set val(ll) LL                                          ;# link layer type
set val(ant) Antenna/OmniAntenna                        ;# antenna model
set val(ifqlen) 50                                      ;# max packet in ifq
set val(rp) DSDV                                        ;# routing protocol
#------------------------------------------------------------------------------------


#=========================================================================
# initialize ns
#=========================================================================

#=========================================================================
# initialize ns
#=========================================================================

#=========================================================================
# initialize ns
#=========================================================================

#=========================================================================
# initialize ns
#=========================================================================

#=========================================================================
# initialize ns
#=========================================================================

#=========================================================================
# initialize ns
#=========================================================================
