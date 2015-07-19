FROM centos:centos6

#RUN yum -y install epel-release

RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm && \
	yum -y install puppet

#yum -y update

CMD ["/usr/bin/puppet"]
