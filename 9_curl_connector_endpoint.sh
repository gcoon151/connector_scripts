#!/bin/bash
# The resources offered through connector are by default exposed
# on the IBM private network so it's recommended to use cloud shell to easily
# get on that network https://cloud.ibm.com/shell
ibmcloud sat endpoint ls --connector `awk -F= '$1=="SATELLITE_CONNECTOR_ID"{print $2}' ./env-files/env.txt` 
...add here grab region for next curl command from json output and maybe echo some export $CONNECTORTARGET=VALUE:PORT
# Take this command to cloud shell if you're not already in it
# Simple hit TCP port
curl telnet://c-01.private.us-south.link.satellite.cloud.ibm.com:YOURPORT
#debug 
curl -v telnet://c-01.private.us-south.link.satellite.cloud.ibm.com:YOURPORT
# dig command with trace and debug for DNS shenanigans
# 
