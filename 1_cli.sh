#/bin/bash
# https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli
echo "When it asks for a password, it's referring to your Mac OS password";
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh
# This installs the container service plugin which has the Satellite commands. 
ibmcloud plugin install ks
