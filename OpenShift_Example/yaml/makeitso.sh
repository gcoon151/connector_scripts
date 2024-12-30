echo need to move the sanitized ones into these first and then fill them out. 
oc new-project agent1
oc create -f agent-configmap.yaml
oc create -f agent.yaml
