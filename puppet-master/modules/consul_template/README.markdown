#consul_template for Puppet

##Installation

###What This Module Affects

* Installs the consul-template binary (via url or package)
* Optionally installs a user to run it under
* Installs a configuration file (/etc/consul-template/config.json)
* Manages the consul-template service via upstart, sysv, or systemd


##Parameters

- `purge_config_dir` **Default**: true. If enabled, removes config files no longer managed by Puppet.
- `bin_dir` **Default**: /usr/local/bin. Path to the consul-template binaries
- `arch` **Default**: Read from facter. System architecture to use (amd64, x86_64, i386)
- `version` **Default**: 0.6.0. Version of consul-template to install
- `install_method` **Default**: url. When set to 'url', consul-template is downloaded and installed from source. If
set to 'package', its installed using the system package manager.
- `os` **Default**: Read from facter.
- `download_url` **Default**: https://github.com/hashicorp/consul-template/releases/download/v${version}/consul-template_${version}_${os}_${arch}.tar.gz. URL to download consul-template from (when `install_method` is set to 'url')
- `package_name` **Default**: consul-template. Name of package to install
- `package_ensure` **Default**: latest.
- `config_dir` **Default**: /etc/consul-template. Path to store the consul-template configuration
- `extra_options` Default: ''. Extra options to be bassed to the consul-template agent. See https://github.com/hashicorp/consul-template#options
- `service_enable` Default: true.
- `service_ensure` Default: running.
- `consul_host` Default: localhost. Hostanme of consul agent to query
- `consul_port` Default: 8500. Port number the API is running on
- `consul_token` Default: ''. ACL token to use when querying consul
- `consul_retry` Default: 10s. Time in seconds to wait before retrying consul requests
- `init_style` Init style to use for consul-template service.
- `log_level` Default: info. Logging level to use for consul-template service. Can be 'debug', 'warn', 'err', 'info'



##Usage

The simplest way to use this module is:
```puppet
include consul_template
```

Or to specify parameters:
```puppet
class { 'consul_template':
    service_enable => false
    log_level      => 'debug',
    init_style     => 'upstart'
}
```


## Watch files

To declare a file that you wish to populate from Consul key-values, you use the
`watch` define. This requires a source `.ctmpl` file and the file on-disk
that you want to update.

```puppet
consul_template::watch { 'common':
    template    => 'data/common.json.ctmpl.erb',
    destination => '/tmp/common.json',
    command     => 'true',
}
```

##Limitations

Depends on the JSON gem, or a modern ruby.

##Development
See the [contributing guide](CONTRIBUTING.md)

Open an [issue](https://github.com/gdhbashton/puppet-consul_template/issues) or
[fork](https://github.com/gdhbashton/puppet-consul_template/fork) and open a
[Pull Request](https://github.com/gdhbashton/puppet-consul_template/pulls)
