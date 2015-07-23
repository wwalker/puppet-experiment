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

