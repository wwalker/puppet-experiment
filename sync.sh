#!/bin/bash

#set -e -o pipefail

readonly pm_host=$(gcloud compute instances describe puppet --format json|jq -r .networkInterfaces[0].accessConfigs[0].natIP)

rsync -avx -e ssh --delete ./puppet-master/ "${pm_host}":puppet/
	
#for node in puppet node1 node2 node3; do
#	ssh root@${node}.lxc puppet agent --test
#done
