#!/bin/bash

set -e -o pipefail

#	-u=$(id -u) \

sudo docker run --rm -it \
	-v $PWD/puppet-master:/etc/puppet \
	naelyn/fakepuppet \
	"$@"

sudo chown -R $(id -u):$(id -g) $PWD/puppet-master
