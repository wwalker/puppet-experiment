#!/bin/bash

set -e -o pipefail

if [[ $# != 1 ]]; then
	echo "wrong arg count, expected 1 got $#" >&2
	exit 2
fi

readonly cmd="$1"

vagrant up --no-parallel

[[ -e ssh.config ]] || {
	vagrant ssh-config > ssh.config
}

#ssh -F ssh.config

case "${cmd}" in
	start)
		dpkg -s yum | grep -q "Status: install ok installed" || {
			sudo apt-get install -y yum
		}
		sudo lxc-ls -1 | grep -q puppet || {
			sudo lxc-create -t centos -n puppet
		}
		sudo lxc-ls -1 | grep -q node1 || {
			sudo lxc-create -t centos -n node1
		}

		ip_pm=$(sudo lxc-info -n puppet | grep "^IP:" | awk '{print $2}')
		ip_n1=$(sudo lxc-info -n node1 | grep "^IP:" | awk '{print $2}')
		echo "${ip_pm} puppet" > hosts
		echo "${ip_n1} node1" >> hosts
		;;
	init)
		[[ -e ./hosts ]] || {
			echo "please run ./tool.sh start first" >&2
			exit 2
		}
		ip_pm=$(grep "\bpuppet$" ./hosts | awk '{print $1}')
		ip_n1=$(grep "\bnode1$" ./hosts | awk '{print $1}')

		echo "Root: $(sudo cat /var/lib/lxc/puppet/tmp_root_pass)"
		echo "Change password to 'correct horse' then immediately change to 'puppet"
		ssh root@$ip_pm
		ssh-copy-id root@$ip_pm

		echo "Root: $(sudo cat /var/lib/lxc/node1/tmp_root_pass)"
		echo "Change password to 'correct horse' then immediately change to 'puppet"
		ssh root@$ip_n1
		ssh-copy-id root@$ip_n1
		;;
	ssh-puppet)
		[[ -e ./hosts ]] || {
			echo "please run ./tool.sh start first" >&2
			exit 2
		}
		ip=$(grep "\bpuppet$" ./hosts | awk '{print $1}')
		ssh root@$ip
		;;
	ssh-node1)
		[[ -e ./hosts ]] || {
			echo "please run ./tool.sh start first" >&2
			exit 2
		}
		ip=$(grep "\bnode1$" ./hosts | awk '{print $1}')
		ssh root@$ip
		;;
	*)
		echo "invalid command '${cmd}" >&2
		exit 2
		;;
esac
