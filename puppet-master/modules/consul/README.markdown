#puppet-consul
[![Build Status](https://travis-ci.org/solarkennedy/puppet-consul.png)](https://travis-ci.org/solarkennedy/puppet-consul)

##Installation

##Compatibility

Any module release that is tagged with 0.4.* is compatible with the 0.4.x
versions of consul. Anything tagged with 0.5.* is compatible with consul
0.5.x, etc.

So, if you are using consul 0.4.1, try to use the lastes tagged release
on the 4 series. Do *not* pull from master.

###What This Module Affects

* Installs the consul daemon (via url or package)
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul/config.json)
* Manages the consul service via upstart, sysv, or systemd
* Optionally installs the Web UI

##Usage

To set up a single consul server, with several agents attached:
On the server:
```puppet
class { '::consul':
  config_hash => {
    'bootstrap_expect' => 1,
    'data_dir'         => '/opt/consul',
    'datacenter'       => 'east-aws',
    'log_level'        => 'INFO',
    'node_name'        => 'server',
    'server'           => true,
  }
}
```
On the agent(s):
```puppet
class { '::consul':
  config_hash => {
    'data_dir'   => '/opt/consul',
    'datacenter' => 'east-aws',
    'log_level'  => 'INFO',
    'node_name'  => 'agent',
    'retry_join' => ['172.16.0.1'],
  }
}
```

##Web UI

To install and run the Web UI on the server, include `ui_dir` in the
`config_hash`. You may also want to change the `client_addr` to `0.0.0.0` from
the default `127.0.0.1`, for example:
```puppet
class { '::consul':
  config_hash => {
    'bootstrap_expect' => 1,
    'client_addr'      => '0.0.0.0',
    'data_dir'         => '/opt/consul',
    'datacenter'       => 'east-aws',
    'log_level'        => 'INFO',
    'node_name'        => 'server',
    'server'           => true,
    'ui_dir'           => '/opt/consul/ui',
  }
}
```
For more security options, consider leaving the `client_addr` set to `127.0.0.1`
and use with a reverse proxy:
```puppet
  $aliases = ['consul', 'consul.example.com']

  # Reverse proxy for Web interface
  include 'nginx'

  $server_names = [$::fqdn, $aliases]

  nginx::resource::vhost { $::fqdn:
    proxy       => 'http://localhost:8500',
    server_name => $server_names,
  }
```

## Service Definition

To declare the availability of a service, you can use the `service` define. This
will register the service through the local consul client agent and optionally
configure a health check to monitor its availability.

```puppet
::consul::service { 'redis':
  checks  => [
    {
      script   => '/usr/local/bin/check_redis.py',
      interval => '10s'
    }
  ],
  port    => 6379,
  tags    => ['master']
}
```

See the service.pp docstrings for all available inputs.

You can also use `consul::services` which accepts a hash of services, and makes
it easy to declare in hiera.

## Watch Definitions

```puppet
::consul::watch { 'my_watch':
  handler     => 'handler_path',
  passingonly => true,
  service     => 'serviceName',
  service_tag => 'serviceTagName',
  type        => 'service',
}
```

See the watch.pp docstrings for all available inputs.

You can also use `consul::watches` which accepts a hash of watches, and makes
it easy to declare in hiera.

## Check Definitions

```puppet
::consul::check { 'true_check':
  interval => '30s',
  script   => '/bin/true',
}
```

See the check.pp docstrings for all available inputs.

You can also use `consul::checks` which accepts a hash of checks, and makes
it easy to declare in hiera.

## ACL Definitions

```puppet
consul_acl { 'ctoken':
  ensure => 'present',
  rules  => {'key' => {'test' => {'policy' => 'read'}}},
  type   => 'client',
}
```

Do not use duplicate names, and remember that the ACL ID (a read-only property for this type)
is used as the token for requests, not the name

##Limitations

Depends on the JSON gem, or a modern ruby.

##Development
Open an [issue](https://github.com/solarkennedy/puppet-consul/issues) or
[fork](https://github.com/solarkennedy/puppet-consul/fork) and open a
[Pull Request](https://github.com/solarkennedy/puppet-consul/pulls)
