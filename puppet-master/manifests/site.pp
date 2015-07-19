# -*- mode: puppet -*-

class common {
  class { 'timezone':
    region   => 'America',
    locality => 'Chicago',
  }

  package { "curl":
    ensure => "installed"
  }
  package { "jq":
    ensure => "installed"
  }
  package { "nmap":
    ensure => "installed"
  }
  package { "ntp":
    ensure => "installed"
  }
  package { "ntpdate":
    ensure => "installed"
  }
  package { "rsync":
    ensure => "installed"
  }
  package { "tar":
    ensure => "installed"
  }
  package { "vim-enhanced":
    ensure => "installed"
  }
  package { "wget":
    ensure => "installed"
  }
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

node 'padm1' {
  include common
  include consul_server
}

node 'pnode1', 'pnode2', 'pnode3' {
  include common
  include consul_agent
}

node default {
  include common
  include consul_agent
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

