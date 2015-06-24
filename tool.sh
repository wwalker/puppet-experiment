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

case "${1}" in
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
	*)
		echo "unknown command: ${1}" >&2
		exit 1
		;;
esac
