#!/bin/bash

rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm/tmp/epel-release-6-8.noarch.rpm
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

yum -y update
yum -y install puppet-server rsync
puppet resource package puppet-server ensure=latest

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

    dns_alt_names = puppet

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

puppet resource service puppetmaster ensure=running enable=true

## manual ##
# puppet cert list
# puppet cert sign --all

