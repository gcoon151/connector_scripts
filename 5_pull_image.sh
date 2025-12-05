#!/bin/bash
# or change docker to nerdctl for rancher
podman pull us.icr.io/armada-master/satellite-connector-agent:latest
# I know I should put the public one icr.io/ibm/satellite-connector/satellite-connector-agent:latest 
# but authentication is such a pain some times and I like things working by default. 
# The uncommented docker pull command above grabs a version of the agent that doesn't require logging in. 
