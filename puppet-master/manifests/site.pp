# -*- mode: puppet -*-

class common {
  package { "jq":
    ensure => "installed"
  }
  package { "libcgroup":
    ensure => "installed"
  }
  package { "tar":
    ensure => "installed"
  }

  service { "cgconfig":
    ensure => "running",
    enable => true,
  }

  include docker
}

class consul_server {
  class { '::consul':
    config_hash => {
      'bootstrap_expect' => 1,
      'data_dir'         => '/opt/consul',
      'datacenter'       => 'dc1',
      'log_level'        => 'INFO',
      'node_name'        => $hostname,
      'server'           => true,
      'ui_dir'           => '/opt/consul/ui',
      'client_addr'      => '0.0.0.0',
      'advertise_addr'   => $ipaddress_eth0,
    }
  }
}

class consul_agent {
  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'dc1',
      'log_level'  => 'INFO',
      'node_name'  => $hostname,
      'retry_join' => [$serverip],
      'advertise_addr' => $ipaddress_eth0,
      'client_addr'   => '127.0.0.1',
    }
  }
}

#  service { "docker":
#    ensure => "running",
#    enable => true,
#  }

node 'puppet' {
  include common
  include consul_server
}

node 'node1','node2', 'node3' {
  include common
  include consul_agent
}

node default {
  include common
}

#node 'node1' {
#  file {'/tmp/node1':
#    ensure => absent,
#  }
#}

#node default {
#  file {'/tmp/defaultnode':
#    ensure => absent,
#  }
#}

#file {'/tmp/example-ip':
#  ensure  => absent,
#  content => "Here is my Public IP Address: ${ipaddress_eth0}.\n", 
#}

