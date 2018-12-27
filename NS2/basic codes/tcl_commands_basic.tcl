#intro to basic commands of tcl - btw this is a comment
# if you comment something in same line of a code then add ';' before '#'

#print
puts "puts command is equivalent to printf"

#set variable
set x 5
puts $x

#expression
puts [expr 1+3]
set x [expr 107+1]
puts $x
puts [expr $x-138]

#conditions

#ternary
set x 5
set y 6

set x [expr $x < $y ? 10 : 20]
puts $x

#normal if - writing in this format is necessary
if {$x > $y} then {
    puts "x > y" 
} else {
    puts "x < y
}

#for loop
for {set i 0} {$i < 10} {set i [expr $i + 1]} {
    puts $i
}