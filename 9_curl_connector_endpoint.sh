#!/bin/bash
# The resources offered through connector are by default exposed
# on the IBM private network so it's recommended to use cloud shell to easily
# get on that network https://cloud.ibm.com/shell
echo "This is the target interface NOTE ONLY REACHABLE from within IBM Cloud"
ibmcloud sat endpoint get --endpoint localhostendpoint9k1 --connector-id `sed -n 's/^SATELLITE_CONNECTOR_ID=//p' env-files/env.txt`|grep Address|sed -n 's/^.*TCP //p'
# Take this command to cloud shell if you're not already in it
# Simple hit TCP port
echo "now curl it from https://cloud.ibm.com/shell" 
echo "Debug like: curl -v telnet://c-01.private.us-south.link.satellite.cloud.ibm.com:YOURPORT"
# dig command with trace and debug for DNS shenanigans
# 
