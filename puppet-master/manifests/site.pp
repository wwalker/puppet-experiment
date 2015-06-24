# -*- mode: ruby -*-
node default {
  package { "tar":
    ensure => "installed"
  }
  package { "libcgroup":
    ensure => "installed"
  }


  service { "cgconfig":
    ensure => "running",
    enable => true,
  }


  class {'docker':
  }
}
#  include docker

#  service { "docker":
#    ensure => "running",
#    enable => true,
#  }

node 'puppet' {
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
        'advertise_addr'   => $ipaddress,
    }
  }
}

node 'node1','node2' {
  class { '::consul':
    config_hash => {
        'data_dir'   => '/opt/consul',
        'datacenter' => 'dc1',
        'log_level'  => 'INFO',
        'node_name'  => $hostname,
        'retry_join' => ['10.11.1.2'],
        'advertise_addr'   => '127.0.0.1',
    }
  }
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

