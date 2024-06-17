#!/bin/bash
# GUI has this for the moment https://cloud.ibm.com/satellite/connectors/
ibmcloud sat endpoint create --connector-id `sed -n 's/^SATELLITE_CONNECTOR_ID=//p' env-files/env.txt` --source-protocol TCP --dest-hostname localhost --dest-port 9001
