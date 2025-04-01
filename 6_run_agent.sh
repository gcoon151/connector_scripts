#!/bin/bash
echo "Hint if you have ARM mac, use rancher and change this to nerdctl in the script. Rancher works best on ARM macs"; 
echo "Now have arm agent images. May not be an issue any more."
# additional notes on rancher I use containerd and don't even start the kubernetes stuff
docker run -d --network host --platform linux/amd64 --env-file ~/agent/env-files/env.txt -v ~/agent/env-files:/agent-env-files us.icr.io/armada-master/satellite-connector-agent:latest
# Use this one for production: icr.io/ibm/satellite-connector/satellite-connector-agent:latest
# The one above is unauthenticated by default and just easier for first timers. Best way to authenticate and pull
# image is with the ibmcloud cr (container registry) plugin. It can configure docker/podman to pull images. 
# for openshift, you'll need to configure pull secrets. Same as setting up for docker hub authentication. 
