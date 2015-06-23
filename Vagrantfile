# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

$num_node = 2

$vb_puppet_memory = 512
$vb_node_memory = 512

$ip_base = '10.11.1.'

$puppet_ip = $ip_base + "2"

$node_ips = $num_node.times.collect { |n| $ip_base + "#{n+3}" }
$node_ips_str = $node_ips.join(",")

# This stuff is cargo-culted from
# http://www.stefanwrobel.com/how-to-make-vagrant-performance-not-suck.
# Give access to half of all cpu cores on the host. We divide by 2 as we
# assume that users are running with hyperthreads.
#
# rboyer: stole this from
# https://github.com/GoogleCloudPlatform/kubernetes/blob/master/Vagrantfile
#
$vb_cpus = (`nproc`.to_i/2.0).ceil
#$vb_cpus = 1

Vagrant.configure(2) do |config|
  #config.vm.box = "chef/centos-6.6"
  config.vm.box = "naelyn/chef-centos-6.6-current"

  config.vm.synced_folder '.', '/vagrant', disabled: true

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    #config.cache.scope = :machine
    config.cache.auto_detect = false
    config.cache.enable :yum
    
    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end

  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    
    vb.cpus = $vb_cpus

    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end
  
  config.vm.define 'puppet' do |node|
    node.vm.hostname = 'puppet'

    node.vm.network :private_network, ip: $puppet_ip, :netmask => "255.255.0.0"

    node.vm.provider :virtualbox do |vb|
      vb.memory = $vb_puppet_memory
    end
    
    node.vm.provision "shell", inline: <<-SHELL
     sudo yum -y update
    SHELL
  end

  $num_node.times do |i|
    vm_name = "node%d" % (i+1)

    config.vm.define 'node1' do |node|
      node.vm.hostname = vm_name
      
      node_index = i+1
      node_ip = $node_ips[i]

      node.vm.network :private_network, ip: "#{node_ip}", :netmask => "255.255.0.0"
      
      node.vm.provider :virtualbox do |vb|
        vb.memory = $vb_node_memory
      end
      
      node.vm.provision "shell", inline: <<-SHELL
       sudo yum -y update
      SHELL
    end
  end
end
