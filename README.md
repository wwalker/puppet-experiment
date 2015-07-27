# First pin ourselves to a specific region and zone

    gcloud config set compute/region us-central1
    gcloud config set compute/zone us-central1-a

# Create base image for centos 7 without selinux

    gcloud compute instances create centos-7-nose --image centos-7 --machine-type g1-small
    gcloud compute ssh centos-7-nose

Now once you're in the box:

    sudo su
    sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/sysconfig/selinux
    sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config
    setenforce 0 || echo "can't setenforce 0"
	reboot
	getenforce
	poweroff

Get back to your host machine:

    gcloud compute instances delete centos-7-nose --keep-disks boot
    gcloud compute images create centos-7-nose --source-disk centos-7-nose 
    gcloud compute disks delete centos-7-nose

# Create base image for centos 6 without selinux

    gcloud compute instances create centos-6-nose --image centos-6 --machine-type g1-small
    gcloud compute ssh centos-6-nose

Now once you're in the box:

    sudo su
    sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/sysconfig/selinux
    sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config
    setenforce 0 || echo "can't setenforce 0"
	reboot
	getenforce
	poweroff

Get back to your host machine:

    gcloud compute instances delete centos-6-nose --keep-disks boot
    gcloud compute images create centos-6-nose --source-disk centos-6-nose 
    gcloud compute disks delete centos-6-nose

# Create our infra

    gcloud compute instances create puppet --image centos-6-nose --machine-type g1-small --metadata-from-file startup-script=gce-init/startup.master.sh
    gcloud compute instances create node1 node2 node3 --image centos-6-nose --machine-type g1-small --metadata-from-file startup-script=gce-init/startup.node.sh

    gcloud compute instances create node4 --image centos-7-nose --machine-type g1-small --metadata-from-file startup-script=gce-init/startup.node7.sh

Examine what we've built:

    gcloud compute instances list

# Accept the certs

    sudo puppet cert list
	sudo puppet cert sign --all

Remove the GCE startup script from the puppet master

# For the puppet master, push the repo into the GCE git repos

Update git to 1.8+:

    sudo rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	sudo yum -y install subversion
    sudo yum -y --disablerepo=base,updates --enablerepo=rpmforge-extras update subversion
    sudo yum -y --disablerepo=base,updates --enablerepo=rpmforge-extras update git

Update gcloud on the box:

	sudo /usr/local/bin/gcloud components update
	sudo /usr/local/bin/gcloud components update alpha

ROOT: Create a Service Account and copy the files to /root:

    PATH="/usr/local/bin:${PATH}" gcloud auth activate-service-account --key-file PATH_TO_FILE.json

ROOT: Do the git clone:

    PATH="/usr/local/bin:${PATH}" gcloud alpha source clone default puppet

ROOT: Auto clone $HOME/puppet/ to /etc/puppet/

    puppet resource cron puppetclone environment='PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' command='cd /root/puppet && git checkout master && git reset --hard origin/master && git pull && sync && touch .last_pulled && rsync --delete -avxHW /root/puppet/puppet-master/ /etc/puppet/ && sync' user=root minute='*/1'

This makes:

    cron { 'puppetclone':
      ensure      => 'present',
      command     => 'cd /root/puppet && git checkout master && git reset --hard origin/master && git pull && touch .last_pulled && rsync -avx /root/puppet/puppet-master/ /etc/puppet/',
      environment => ['PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'],
      minute      => ['*/1'],
      target      => 'root',
      user        => 'root',
    }



    puppet resource cron puppetclone environment='PATH=/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' \
        user=root
        minute='*/1'

