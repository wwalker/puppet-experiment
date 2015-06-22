#!/bin/bash

set -e -o pipefail

[[ $(sudo lxc-ls | wc -l) -gt 0 ]] && {
	echo "must erase things"
	for ctr in $(sudo lxc-ls -1); do
		echo "erasing lxc host: $ctr"
		sudo lxc-destroy -n "${ctr}" -f
	done
}

echo "shutting down system services"
sudo service dnsmasq stop || echo "not stopping dnsmasq"
sudo service lxc-net stop || echo "not stopping lxc-net"

#echo "wiping old DHCP leases"
#sudo rm /var/lib/misc/dnsmasq.lxcbr0.leases

echo "bringing up just lxc networking"
sudo service lxc-net start
sudo service lxc-net restart
sudo service dnsmasq start

echo "creating 'puppet' container"
sudo lxc-create -t centos -n puppet.lxc

echo "starting 'puppet' container in background"
sudo lxc-start -d -n puppet.lxc
sudo lxc-wait -n puppet.lxc -s RUNNING

while true; do
	ps aux | grep "lxc.*dnsmasq.*bind"
	sudo lxc-ls --fancy
	sleep 5
done

