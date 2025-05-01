# Note this might be a better test https://cloud.ibm.com/docs/satellite?topic=satellite-end-to-end
# but this script is meant to run outside of a container on your host to 
# just launch a very basic web service that serves up a file somefile.txt over HTTP. 
#!/bin/bash
mkdir webdemo
# This is the data file served up. 
echo "I am data " > webdemo/somefile.txt
cd webdemo
# The ampersand at the end launches the python command to the background. 
# "fg" in bash will bring it back for you to ctrl-c it or you can just kill it
# from the process list
python3 -m http.server 9000 &
