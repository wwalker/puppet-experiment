# http://www.cloudera.com/content/cloudera/en/documentation/archives/cloudera-manager-4/v4-5-1/Cloudera-Manager-Enterprise-Edition-Installation-Guide/cmeeig_topic_21_3.html

yum install createrepo rpm-build

yum install ruby-devel gcc
gem install fpm

## consul
0.5.2 x86_64

## serve
yum install httpd
service httpd start
mkdir -p /var/www/html/repo
cp *.rpm /var/www/html/repo
cd /var/www/html/repo
createrepo .
chmod -R ugo+rX /var/www/html/repo

#### clients
yumrepo { "myrepo":
baseurl =>
"http://local.server.org/myrepo/$operatingsystem/$operatingsystemrelease/$architecture",
descr => "My Local Repo",
enabled => 1,
gpgcheck => 0,
}


############################
# if you update the RPMs without bumping the versions you'll have to
# 'sudo yum clean all' on all boxes
