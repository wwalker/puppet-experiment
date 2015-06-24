# -*- mode: markdown -*-

# First pin ourselves to a specific region and zone

    gcloud config set compute/region us-central1
    gcloud config set compute/zone us-central1-a

# Create base image for centos

    gcloud compute instances create centos-6-base --image centos-6 --machine-type f1-micro
    gcloud compute ssh centos-6-base

Now once you're in the box:

    sudo su
    rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm/tmp/epel-release-6-8.noarch.rpm
    yum -y update
    yum -y install rsync nmap vim wget curl git
	# edit /etc/sysconfig/selinux
	#   SELINUX=disabled
	reboot
	poweroff

Get back to your host machine:

    gcloud compute instances delete centos-6-base --keep-disks boot
    gcloud compute images create centos-6-base --source-disk centos-6-base 
    gcloud compute disks delete centos-6-base

# Create the base image for the puppet nodes

    gcloud compute instances create puppet-node-base --image centos-6-base --machine-type f1-micro
    gcloud compute ssh puppet-node-base

Now once you're in the box:

    sudo su
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
    yum -y install puppet
    puppet resource package puppet ensure=latest
    # edit /etc/puppet/puppet.conf
    # [main]
	# ...
    # server = puppet
    # DO NOT START PUPPET AGENT YET (so we avoid doing the TLS dance with the wrong hostname)
    # poweroff

Get back to your host machine:

    gcloud compute instances delete puppet-node-base --keep-disks boot
    gcloud compute images create puppet-node-base --source-disk puppet-node-base 
    gcloud compute disks delete puppet-node-base

# With our images, create our infra

    gcloud compute instances create puppet --image centos-6-base --machine-type f1-micro \
	    --metadata-from-file startup-script=gce-init/startup.master.sh
    for node in node1 node2; do
	    gcloud compute instances create "${node}" --image puppet-node-base --machine-type f1-micro \
		    --metadata-from-file startup-script=gce-init/startup.node.sh
    done
 
Examine what we've built:

    gcloud compute instances list

# Accept the certs

    sudo puppet cert list
	sudo puppet cert sign --all

# Make the puppet master also an agent (kinda)

    sudo puppet resource cron puppetapply command='puppet agent --test' user=root minute='*/1'

# Auto clone $HOME/puppet/ to /etc/puppet/

    sudo puppet resource cron puppetclone command='rsync -avx --delete --dry-run /home/naelyn/puppet/ /etc/puppet/' user=root minute='*/1'

# (OPTIONAL) For the puppet master, push the repo into the GCE git repos

Update git to 1.8+:

    sudo rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	sudo yum -y install subversion
    sudo yum --disablerepo=base,updates --enablerepo=rpmforge-extras update subversion
    sudo yum --disablerepo=base,updates --enablerepo=rpmforge-extras update git

Update gcloud on the box and do the git clone:

	sudo /usr/local/bin/gcloud components update
	gcloud auth login
	gcloud init puppet-experiment

