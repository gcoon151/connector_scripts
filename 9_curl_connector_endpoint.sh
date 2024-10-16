#!/bin/bash
# The resources offered through connector are by default exposed
# on the IBM private network so it's recommended to use cloud shell to easily
# get on that network https://cloud.ibm.com/shell
# If you want to get really fancy you can set up another endpoint that is "on cloud" pointing to that c-01 name and then it's exposed
# where you're running the agent. Ideally they aren't usally running on the same connector bc why would you bounnce out to my
# service just to return back to your laptop, but it can be handy for understanding how connectors and endpoints work and 
# bringing it all local. 
# if you decide to do that oncloud endpoint, make sure to map the port! 
# https://cloud.ibm.com/docs/satellite?topic=satellite-connector-create-endpoints&interface=cli#configure-connector-oncloud-port
echo "This is the target interface NOTE ONLY REACHABLE from within IBM Cloud"
ibmcloud sat endpoint get --endpoint localhostendpoint9k1 --connector-id `sed -n 's/^SATELLITE_CONNECTOR_ID=//p' env-files/env.txt`|grep Address|sed -n 's/^.*TCP //p'
# Take this command to cloud shell if you're not already in it
# Simple hit TCP port
echo "now curl it from https://cloud.ibm.com/shell" 
echo "Debug like: curl -v telnet://c-01.private.us-south.link.satellite.cloud.ibm.com:YOURPORT"
# dig command with trace and debug for DNS shenanigans
# 
