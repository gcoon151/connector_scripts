#/bin/bash
ansible-playbook -k -u vpcuser -i inventory -e satellite_connector_id=REPLACEMEWITHAVALIDCONNECTORID -e satellite_region=ca-tor install-satellite-agent.yml 
