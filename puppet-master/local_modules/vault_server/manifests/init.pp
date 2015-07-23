# out of band, do this
# cfssl gencert -ca ca.pem -ca-key ca-key.pem csr_node1.json |cfssljson -bare node1
# and copy to /root/vault-key.pem and /root/vault.pem
class vault_server {
  class { 'vault':
    install_method      => 'package',
    backend             => {
        consul          => {
          address       => '127.0.0.1:8500',
          path          => 'vault'
        }
    },
    listener            => {
        tcp             => {
          address       => '0.0.0.0:8200',
#          tls_disable   => 1,
          tls_cert_file => '/root/vault.pem',
          tls_key_file  => '/root/vault-key.pem',
        }
    },
    config_hash         => {
      "advertise_addr"  => $ipaddress_eth0,
    }
  }
}

