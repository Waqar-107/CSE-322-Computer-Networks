# screen - to split the terminal in pieces:
<b>'sudo apt install screen'</b>

<b>'screen'</b> to start

To split the screen vertically use->  <b>'Ctrl+a'</b> then <b>'|'</b>

To splt the screen horizontally use ->  <b>'Ctrl+a'</b> then <b>'Shft+s'</b> ['S' would do if caps lock is on]

To go to next splitted part(they are 0 indexed) use <b>'Ctrl+a'</b> then <b><tab></b>

After going to a new splitted part there we need to use <b>'Ctrl+a'</b> then <b>'c'</b> so that it becomes a terminal

The panes(splitted screens) are like linked list nodes. suppose the main window has been divided into two vertical panes. now it is like 0->1. Now if we split the pane '0' it will be given name '2' and the list would be like, 0->2->1. When we use 'Ctrl+a' and <tab> to switch to next it will do it according to the list demonstrated.

To kill a pane use -> <b>'Ctrl+d'</b>
---------------------------------------------------------------------------------------

# running the codes:

*** the task is done in virtual machine as there is a risk of os crash. in the virtual machine network settings, enable the adapter1 and change it to 'bridge-adapter'

1. "sudo apt install net-tools" so that you can get your 'ifconfig'
type the command 'ifcommand' for your ip and others

2. you will have something like this in the first line -> 'enp0s3', change this in the setup file
with whatever you get

3. change the ip address, the setup file has '192.168.10.something', change with your ip

4. change this in a different file, name it setup.sh, leave the 'setup' file untouched

5. run ./setup.sh

6. next change the topology.txt file, change the ip here, this is the input file, a graph representation

7. change the ip in tehe driver.py

8. then run the file, 'python driver.py topo.txt' -> you may have python3 installed on your device, so you better do-> 'sudo apt install puython'

9. everytime you would need to run setup.sh to create virtual routers(the 4 ip addresses)

10. change the inet address in the cpp-files to, the lines have appropriate comments to find'em

11. there is also a setup file in the cpp, no need to change that

# using the client and the server

1. run the server

2. run a client, give an available ip(the virtual ip you henerated through the ./setup.sh) and your message, the msg will reach the server

that is the end of setup process, now we shall talk about the code.
thanks to my friend spondon(https://github.com/ShanjinurIslam) for the tutorial -> https://www.youtube.com/watch?v=FOc-Ykf6rcY

# running the code - finally!!!:
first use ./setup.sh to create virtual ip's then run driver.py
use ./rn1505107.sh router_number ipAdress to run



