#!/bin/bash
mkdir webdemo
# This is the data file served up. 
echo "I am data " > webdemo/somefile.txt
cd webdemo
# The ampersand at the end launches the python command to the background. 
# "fg" in bash will bring it back for you to ctrl-c it or you can just kill it
# from the process list
python3 -m http.server 9000 &
