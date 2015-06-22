#!/bin/bash

# https://docs.puppetlabs.com/guides/install_puppet/install_el.html
# http://www.tecmint.com/install-puppet-in-centos/
set -e -o pipefail

nodes='node1 node2'

if false; then
	ssh root@${node}.lxc yum -y update
	ssh root@${node}.lxc rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
	ssh root@puppet.lxc yum -y install puppet-server
	
	ssh root@puppet.lxc yum -y install rsync

	puppet resource package puppet-server ensure=latest

	scp ./puppet.master.conf root@puppet.lxc:/etc/puppet/puppet.conf
	ssh root@puppet.lxc puppet master --verbose --no-daemonize	

	ssh root@puppet.lxc puppet resource service puppetmaster ensure=running enable=true
fi

for node in $nodes; do
	if false; then
		ssh root@${node}.lxc yum -y update
		ssh root@${node}.lxc rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
		ssh root@${node}.lxc yum -y install puppet
		ssh root@${node}.lxc puppet resource package puppet ensure=latest
	fi

	scp ./puppet.node.conf root@${node}.lxc:/etc/puppet/puppet.conf

	ssh root@${node}.lxc puppet resource service puppet ensure=running enable=true
done

# ssh root@puppet.lxc
#
# puppet cert list
# puppet cert sign --all

