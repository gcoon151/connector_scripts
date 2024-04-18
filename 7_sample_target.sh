#!/bin/bash
mkdir webdemo
echo "I am data " > webdemo/somefile.txt
cd webdemo
python3 -m http.server 9000 &
