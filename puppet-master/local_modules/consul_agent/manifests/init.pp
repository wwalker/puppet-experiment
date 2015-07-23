class consul_agent(
  $join_servers = [],
) {
  validate_array($join_servers)

  class { "::consul":
    install_method       => 'package',
    config_defaults => hiera_hash('consul::config_hash'),
    config_hash => {
      "node_name"      => $hostname,
      "retry_join"     => $join_servers,
      "advertise_addr" => $ipaddress_eth0,
      "client_addr"    => "127.0.0.1",
    }
  }

  class { "consul_template":
    install_method       => 'package',
  }
}
