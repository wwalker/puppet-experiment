#!/bin/bash
#

if [[ -z "$1" ]]; then
	echo $"Usage: $0 <VERSION>"
	exit 1
fi

VERSION=$1

ZIP_UI=${VERSION}_web_ui.zip

URL_UI="https://dl.bintray.com/mitchellh/consul/${ZIP_UI}"
echo $"Creating consul-ui RPM build file version ${VERSION}"

curl -k -L -o $ZIP_UI $URL_UI || {
	echo $"URL or version not found!" >&2
	exit 1
}

# clear target foler
rm -rf target/*

# create target structure
uidir=/usr/local/consul/ui
mkdir -p target/$uidir target/usr/local/bin

# unzip
unzip -qq ${ZIP_UI} -d target/$uidir
mv target/$uidir/dist/* target/$uidir
rm -rf target/$uidir/dist
rm ${ZIP_UI}

# create rpm (consul_ui requires consul)
fpm -s dir \
	-t rpm \
	-f \
    -C target \
	-n consul_ui \
    -v ${VERSION} \
    -p target \
    -d "consul" \
    --rpm-ignore-iteration-in-dependencies \
    --description "Consul UI RPM package for RedHat Enterprise Linux 6" \
    --url "https://consul.io" \
    usr

rm -rf target/usr
