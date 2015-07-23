class vault_commands {
  class { 'vault':
    install_method => 'package',
    manage_service => false,
  }
}
