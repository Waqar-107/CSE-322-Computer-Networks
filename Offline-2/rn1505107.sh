#!/bin/bash

rname="router"$1".out"
rname2="./"$rname

g++ 1505107.cpp -o $rname
$rname2 $2 "topo.txt"
