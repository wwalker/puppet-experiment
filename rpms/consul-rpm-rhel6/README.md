Consul-rpm-rhel6
================

Building the **consul** and **consul-template** RPM packages for RedHat Enterprise Linux 6.


Requirements
-------------------

* fpm
* rpmbuild

To see how to install and use fmp have a look at: <https://github.com/jordansissel/fpm>

How it works?
-------------------

* build-rpm-consul.sh creates a consul rpm
* build-rpm-consul-ui.sh creates a consul-ui rpm
* build-rpm-consul-template.sh creates a consul-template rpm

The new RPM file is located in the target folder. The target folder will be overridden
when the next build starts.
