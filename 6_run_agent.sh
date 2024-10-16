#!/bin/bash
echo "Hint if you have ARM mac, use rancher and change this to nerdctl in the script. Rancher works best on ARM macs"; 
# additional notes on rancher I use containerd and don't even start the kubernetes stuff
docker run -d --network host --platform linux/amd64 --env-file ~/agent/env-files/env.txt -v ~/agent/env-files:/agent-env-files icr.io/ibm/satellite-connector/satellite-connector-agent:latest
