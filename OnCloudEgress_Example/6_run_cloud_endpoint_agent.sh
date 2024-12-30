#!/bin/bash
# replace nerdctl with podman or docker or whatever you use. Most of them support the -p which is the critical part here. 
# the port numbers need to match 1. What the service assigned the port (will show on the UI and CLI) and 2 what port you want to expose it on
# The example takes an endpoint that was assigned 29999 and exposes the service you're using on 32645. 
# NOTE this path way will likely break certificates you try to use across this because the route you put on your container platform 
# won't match the certificate on the destination service. That's an even more advanced set up where you configure your container platform
# with all the certificates to allow it to be a part of that path. 
nerdctl run --name linkagent2 -d  --sysctl "net.ipv4.ip_unprivileged_port_start=0" -p 32645:29999 --env-file ~/agent/env-files/env.txt --env LOG_LEVEL=trace -v ~/agent/env-files:/agent-env-files icr.io/ibm/satellite-connector/satellite-connector-agent:latest

