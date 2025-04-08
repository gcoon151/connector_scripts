REPO_URL=https://github.com/your-org/your-operator \
SUPPORT_ORG="IBM" \
DISPLAY_NAME="Satellite Connector Agent Operator" \
MAINTAINER_NAME="IBM Cloud Satellite Connector Team" \
MAINTAINER_EMAIL="support@ibm.com" \
OPERATOR_IMAGE=icr.io/armada-master/agent-operator:v0.1.0 \
envsubst < bundle/manifests/agent-operator.v0.1.0.clusterserviceversion.yaml.template \
> bundle/manifests/agent-operator.v0.1.0.clusterserviceversion.yaml

