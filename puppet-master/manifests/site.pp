# -*- mode: puppet -*-

node "puppet" {
  include common
  include consul_agent
  include vault_commands
#  include consul_purge

  service { "puppet":
    ensure => "running",
    enable => true
  }

  package { "puppet-server":
    ensure => "latest"
  }

  cron { "puppetclone":
    ensure      => "present",
    command     => "cd /root/puppet && git checkout master && git reset --hard origin/master && git pull && sync && touch .last_pulled && rsync --delete -avxHW /root/puppet/puppet-master/ /etc/puppet/ && sync",
    environment => ["PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"],
    minute      => ["*/1"],
    target      => "root",
    user        => "root",
  }
}

class role_control {
  include common
  include consul_server
#  include consul_purge
  include vault_server

  service { "puppet":
    ensure => "running",
    enable => true
  }

#  class { "vault":
#    backend        => {}, # enable
#    service_enable => true,
#    service_ensure => "running",
#    manage_service => true,
#    version        => "0.2.0",
#    config_hash    => {
#    },
#  }
}

class role_execute {
  include common
  include consul_agent
  include vault_commands
#  include consul_purge

  service { "puppet":
    ensure => "running",
    enable => true
  }
}

node 'node1' {
  include role_control
}

node 'node2', 'node3' {
  include role_execute
}

node default {
#  include common
}
