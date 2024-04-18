#!/bin/bash
ibmcloud plugin install cr
ibmcloud cr region-set icr.io
cat ./env-files/apikey | docker login -u iamapikey --password-stdin icr.io
