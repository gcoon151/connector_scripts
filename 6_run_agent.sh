#!/bin/bash
docker run -d --network host --platform linux/amd64 --env-file ~/agent/env-files/env.txt -v ~/agent/env-files:/agent-env-files icr.io/ibm/satellite-connector/satellite-connector-agent:latest
