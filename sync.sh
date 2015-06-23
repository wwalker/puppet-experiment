#!/bin/bash

#set -e -o pipefail

rsync -avx -e ssh --delete ./puppet-master/ root@puppet.lxc:/etc/puppet/
	
for node in puppet node1 node2; do
	ssh root@${node}.lxc puppet agent --test
done
