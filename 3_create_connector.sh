#/bin/bash
# unfortunately the ibmcloud cli wants a resource group target for the next command to succeed. 
ibmcloud target -g Default
# Make a connector. 
ibmcloud sat experimental connector create --name connector123 --region us-east
echo "The connectorID needs to go in ./env-files/env.txt";
