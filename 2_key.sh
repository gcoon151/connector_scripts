!/bin/bash
# -sso is because I work for the company, you may not need that part
echo "make sure you're logged in: ibmcloud login -sso"
ibmcloud iam api-key-create connector-key; 
echo "now put the string that says 'API Key' in ./env-files/apikey"

