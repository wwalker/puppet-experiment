#!/bin/bash

set -e -o pipefail

if [[ $# != 1 ]]; then
	echo "wrong arg count, expected 1 got $#" >&2
	exit 2
fi

readonly cmd="$1"

nodes='node1 node2'

vagrant up --no-parallel

[[ -e ssh.config ]] || {
	vagrant ssh-config > ssh.config
}

#ssh -F ssh.config

# host ports
readonly hp_puppet='root@10.11.1.2'

case "${1}" in
	copy-ssh)
		
		;;
	init-tls)
		vagrant ssh puppet -c 'sudo puppet master --verbose --no-daemonize'
		;;
	finish)
		vagrant ssh puppet -c 'sudo puppet resource service puppetmaster ensure=running enable=true'
		vagrant ssh node1 -c 'sudo puppet resource service puppet ensure=running enable=true'
		;;
	listcert)
		vagrant ssh puppet -c 'sudo puppet cert list'
		;;
	signcert)
		vagrant ssh puppet -c 'sudo puppet cert sign --all'
		;;
	sync)
		rsync -avx -e ssh --delete ./puppet-master/ ${hp_puppet}:/etc/puppet/
		vagrant ssh puppet -c 'sudo puppet agent --test'
		vagrant ssh node1 -c 'sudo puppet agent --test'
		;;
	revsync)
		rsync -avx -e ssh --delete ${hp_puppet}:/etc/puppet/ ./puppet-master/
		;;
	*)
		echo "unknown command: ${1}" >&2
		exit 1
		;;
esac
