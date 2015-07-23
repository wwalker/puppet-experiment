class consul_server {
  class { "::consul":
    install_method       => 'package',
    config_defaults      => hiera_hash('consul::config_hash'),
    config_hash          => {
      "bootstrap_expect" => 1,
      "node_name"        => $hostname,
      "server"           => true,
      "ui_dir"           => "/opt/consul/ui",
      "client_addr"      => "0.0.0.0",
      "advertise_addr"   => $ipaddress_eth0,
    }
  }

  class { "consul_template":
    install_method       => 'package',
  }
}
