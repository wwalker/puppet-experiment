#!/bin/bash

set -e -o pipefail

sudo apt-get install yum

#/etc/default/lxc-net
#   LXC_DHCP_RANGE="10.0.3.20,10.0.3.254"
#   LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
#   LXC_DOMAIN="lxc"
#
#/etc/lxc/dnsmasq.conf
#   dhcp-host=NAME,1.2.3.4
#   leasefile-ro
#
# sudo service dnsmasq restart

nodes='puppet node1 node2'

for node in $nodes; do
	sudo lxc-info -n ${node}.lxc || {
		sudo lxc-create -t centos -n $node.lxc
	}
	sudo lxc-info -n ${node}.lxc | grep -q 'State:.*STOPPED' && {
		sudo lxc-start -d -n ${node}.lxc
	}
	sudo lxc-wait -n ${node}.lxc -s RUNNING
done

for node in $nodes; do
	echo "root: $(sudo cat /var/lib/lxc/${node}.lxc/tmp_root_pass)"
	echo "please change to 'correct horse' and then back to 'puppet'"
	ssh root@${node}.lxc
	ssh-copy-id root@${node}.lxc
done
