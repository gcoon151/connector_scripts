#!/bin/bash
# GUI has this for the moment https://cloud.ibm.com/satellite/connectors/
ibmcloud sat endpoint create --dest-hostname d0c0b310-abed-484a-bd10-4a5f80f8dd14.btdkfu0w0p0vutjk0r9g.private.databases.appdomain.cloud  --dest-port 32027 --dest-type cloud --name icddemo1 --connector-id `sed -n 's/^SATELLITE_CONNECTOR_ID=//p' env-files/env.txt` --source-protocol TCP
