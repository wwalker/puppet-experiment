# -*- mode: puppet -*-

class common {
  class { "timezone":
    region   => "America",
    locality => "Chicago",
  }

  package { "curl":
    ensure => "installed"
  }
  package { "epel-release":
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

class consul_purge {
  service { 'consul' :
    ensure => stopped,
  }

  file { "/etc/init.d/consul":
    ensure => absent,
  }
  file { "/usr/local/bin/consul":
    ensure => absent,
  }
  file { "/opt/staging":
    ensure => absent,
    force => yes,
  }
  file { "/etc/consul":
    ensure => absent,
    force => yes,
  }
  file { "/opt/consul":
    ensure => absent,
    force => yes,
  }
}

class consul_server {
  class { "::consul":
    config_defaults => hiera_hash('consul::config_hash'),
    config_hash          => {
      "bootstrap_expect" => 1,
      "node_name"        => $hostname,
      "server"           => true,
      "ui_dir"           => "/opt/consul/ui",
      "client_addr"      => "0.0.0.0",
      "advertise_addr"   => $ipaddress_eth0,
    }
  }
}

class consul_agent {
  class { "::consul":
    config_defaults => hiera_hash('consul::config_hash'),
    config_hash => {
      "node_name"      => $hostname,
      "retry_join"     => [$serverip],
      "advertise_addr" => $ipaddress_eth0,
      "client_addr"    => "127.0.0.1",
    }
  }
}

class rboyer_vault(
  $version = "0.2.0",
) {

  if (!$version) {
    fail "version is not set"
  }  

  # $digest_string
  # $digest_type = "sha256"
  archive {"vault_${version}_linux_amd64":
    ensure           => "present",
    url              => "https://dl.bintray.com/mitchellh/vault/vault_${version}_linux_amd64.zip",
    checksum         => false,
    follow_redirects => true,
    extension        => "zip",
    target           => "/usr/local/bin",
    src_target       => "/tmp",
  }
}

node "puppet" {
  include common
  include consul_server
  #include consul_purge

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

node "node1", "node2", "node3" {
  include common
  include consul_agent
#  include consul_purge

  service { "puppet":
    ensure => "running",
    enable => true
  }
}

node default {
  include common
}

#node "node1" {
#  file {"/tmp/node1":
#    ensure => absent,
#  }
#}

#node default {
#  file {"/tmp/defaultnode":
#    ensure => absent,
#  }
#}

#file {"/tmp/example-ip":
#  ensure  => absent,
#  content => "Here is my Public IP Address: ${ipaddress_eth0}.\n", 
#}

