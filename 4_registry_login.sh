#!/bin/bash
# Install container registry plugin
ibmcloud plugin install cr
# Set global region.
ibmcloud cr region-set icr.io
# login to that container registry - obv requires working docker command or change docker to whatever your container platform is. 
# For rancher I change this to say nerdctl login -u iamapikey --password-stdin icr.io
cat ./env-files/apikey | docker login -u iamapikey --password-stdin icr.io
