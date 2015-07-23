class common {
  class { "timezone":
    region   => "America",
    locality => "Chicago",
  }

  package { "epel-release":
    ensure => "installed"
  }

  ensure_packages(['curl','jq','nmap','ntp','ntpdate','rsync','tar','vim-enhanced','wget'])

  yumrepo { "my-repo":
    # /$operatingsystem/$operatingsystemrelease/$architecture
    baseurl  => "http://puppet.c.puppet-experiment.internal/repo",
    descr    => "My Local Repo",
    enabled  => 1,
    gpgcheck => 0,
  }

  class { "ca_cert": }

  ca_cert::ca { 'Penguin-Farmers-Certificate-Authority': 
    ensure  => 'trusted',
    source  => 'text',
    ca_text => file('common/ca.crt'),
  }
}
