# Install ns2

1. tar zxvf ns-allinone-2.35.tar.gz to unzip the file

2. install gcc-4.8 and g++-4.8 using sudo apt install gcc-4.8 g++-4.8

3. there will be an error because of version-7, so we have to change the compiler for ns2. go to ns-2.35 folder and open Makefile.in and there you will find something like this -> "# The following will be redefined under Windows (see WIN32 lable below) ". under this there is "CC" and "CPP", change it to gcc-4.8 and g++-4.8. then open linkstate/ls.h and goto line 137, there is a "erase", make it "this->erase"

4. edit environment variable, use gedit /home/your_pc_name/.bashrc . there you will add->
export PATH=$PATH: the link givn by ns2 in the terminal
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH: link given in the terminal. replace any comma to ':'

https://www.youtube.com/watch?v=FXm8i1K-6jI&feature=youtu.be&fbclid=IwAR3IXJy_XZ73kyZj889qmg-iMJ7mmWs6D9Z4aiyfHHbBBpunlDqrN6i1nEE

5. ./configure in ns2.35 folder

# Install Nam

1. sudo apt-get purge nam

2. wget --user-agent="Mozilla/5.0 (Windows NT 5.2; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" "http://technobytz.com/wp-content/uploads/2015/11/nam_1.14_amd64.zip"

3. unzip nam_1.14_amd64.zip

4. sudo dpkg -i nam_1.14_amd64.deb

5. sudo apt-mark hold nam


# running things
1. to run .tcl files, use "ns filename.tcl"
