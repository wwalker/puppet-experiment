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

