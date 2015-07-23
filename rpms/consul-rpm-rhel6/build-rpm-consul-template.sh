#!/bin/bash
#

if [[ -z "$1" ]]; then
	echo $"Usage: $0 <VERSION> [ARCH]"
	exit 1
fi

NAME=consul-template
VERSION=$1

if [[ -z "$2" ]]; then
	ARCH=`uname -m`
else
	ARCH=$2
fi

#https://github.com/hashicorp/consul-template/releases/download/v0.2.0/consul-template_0.2.0_linux_amd64.tar.gz
case "${ARCH}" in
	i386)
		TARGZ=${NAME}_${VERSION}_linux_386.tar.gz
		;;
	x86_64)
		TARGZ=${NAME}_${VERSION}_linux_amd64.tar.gz
		;;
	*)
		echo $"Unknown architecture ${ARCH}" >&2
		exit 1
		;;
esac

URL="https://github.com/hashicorp/${NAME}/releases/download/v${VERSION}/${TARGZ}"
echo $"Creating ${NAME} RPM build file version ${VERSION}"

# fetching consul-template
curl -k -L -o $TARGZ $URL || {
	echo $"URL or version not found!" >&2
	exit 1
}

# clear target foler
rm -rf target/*

# create target structure
mkdir -p target/usr/local/bin/

# unzip
tar -xf ${TARGZ} -O > target/usr/local/bin/${NAME}
rm ${TARGZ}

# create rpm
fpm -s dir \
	-t rpm \
	-f \
	-C target \
	-n ${NAME} \
	-v ${VERSION} \
	-p target \
	-d "consul" \
	--rpm-ignore-iteration-in-dependencies \
	--description "Consul-template RPM package for RedHat Enterprise Linux 6" \
	--url "https://github.com/hashicorp/consul-template" \
	usr

rm -rf target/usr
