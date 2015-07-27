#!/bin/bash

if [[ -e /root/.startup.script.run ]]; then
	echo "Skipping startup because /root/.startup.script.run exists"
	exit 0
fi

## this should be part of the centos-7-nose image
sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/sysconfig/selinux
sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config

setenforce 0 || echo "can't setenforce 0"

###################
# COMMON

yum -y install epel-release
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

yum -y install curl jq nmap ntp ntpdate rsync tar vim-enhanced wget 

yum -y update

###################
# NODE

yum -y install puppet
puppet resource package puppet ensure=latest

cat <<'EOF' > /etc/puppet/puppet.conf
[main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '$confdir/ssl'.
    ssldir = $vardir/ssl

	server = puppet
    runinterval = 1m

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig
EOF

puppet resource service puppet ensure=running enable=true


#################
touch /root/.startup.script.run
