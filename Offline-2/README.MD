# screen - to split the terminal in pieces:
<b>'sudo apt install screen'</b>

<b>'screen'</b> to start

To split the screen vertically use->  <b>'Ctrl+a'</b> then <b>'|'</b>

To splt the screen horizontally use ->  <b>'Ctrl+a'</b> then <b>'Shft+s'</b> ['S' would do if caps lock is on]

To go to next splitted part(they are 0 indexed) use <b>'Ctrl+a'</b> then <b><tab></b>

After going to a new splitted part there we need to use <b>'Ctrl+a'</b> then <b>'c'</b> so that it becomes a terminal

The panes(splitted screens) are like linked list nodes. suppose the main window has been divided into two vertical panes. now it is like 0->1. Now if we split the pane '0' it will be given name '2' and the list would be like, 0->2->1. When we use 'Ctrl+a' and <tab> to switch to next it will do it according to the list demonstrated.

To kill a pane use -> <b>'Ctrl+d'</b>
