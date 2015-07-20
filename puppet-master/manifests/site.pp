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

class consul_server {
#  file { "/opt/staging/consul/consul.zip":
#    ensure => absent
#  }
#  file { "/opt/staging/consul/consul_ui.zip":
#    ensure => absent
#  }
#  file { "/usr/local/bin/consul":
#    ensure => absent
#  }
#  file { "/opt/consul/ui":
#    ensure => absent
#  }

  class { "::consul":
#    version => "0.5.2",
#    package_name      => "consul-0.5.2",
#    ui_package_name   => "consul-ui-0.5.2",
#    download_url      => "https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip",
#    ui_download_url   => "https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip",
    config_hash => {
      "bootstrap_expect" => 1,
      "data_dir"         => "/opt/consul",
      "datacenter"       => "dc1",
      "log_level"        => "INFO",
      "node_name"        => $hostname,
      "server"           => true,
      "ui_dir"           => "/opt/consul/ui",
      "client_addr"      => "0.0.0.0",
      "advertise_addr"   => $ipaddress_eth0,
    }
  }
}

class consul_agent {
#  file { "/opt/staging/consul/consul.zip":
#    ensure => absent
#  }
#  file { "/opt/staging/consul/consul_ui.zip":
#    ensure => absent
#  }

  class { "::consul":
#    version => "0.5.2",
#    package_name      => "consul-0.5.2",
#    ui_package_name   => "consul-ui-0.5.2",
#    download_url      => "https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip",
#    ui_download_url   => "https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip",
    config_hash => {
      "data_dir"       => "/opt/consul",
      "datacenter"     => "dc1",
      "log_level"      => "INFO",
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

