# connector_scripts
These all assume you're following the docs: 
https://cloud.ibm.com/docs/satellite?topic=satellite-run-agent-locally

This folder is about deploying an agent directly into openshift

I show here how to do both configmap and a quick and dirty just assign the values (the APIKEY one). 
Ideally you use configmap with some proper secrets manager but there's use cases to just assign the values too. 

Openshift on IBM Cloud gotchas. 
# No storage by default for openshift. Quick fix = EmptyDir 
https://cloud.ibm.com/docs/openshift?topic=openshift-registry#emptydir_internal_registry
# Workers/OCP has no internet access (no public gateway in VPC or "secure by default" enabled.)
https://cloud.ibm.com/docs/openshift?topic=openshift-sbd-allow-outbound
https://cloud.ibm.com/docs/vpc?topic=vpc-create-public-gateways&interface=ui
# Possibly trying to access registry (icr.io) without setting up Openshift with credentials
https://cloud.ibm.com/docs/Registry?topic=Registry-registry_rhos
