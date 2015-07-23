#!/bin/bash

VERSION=0.5.2
TEMPLATE_VERSION=0.10.0
ARCH=x86_64
#ARCH=`uname -m`

./build-rpm-consul.sh "${VERSION}" "${ARCH}"
cp ./target/*.rpm /var/www/html/repo

./build-rpm-consul-ui.sh "${VERSION}"
cp ./target/*.rpm /var/www/html/repo

./build-rpm-consul-template.sh "${TEMPLATE_VERSION}" "${ARCH}"
cp ./target/*.rpm /var/www/html/repo

cd /var/www/html/repo
createrepo .
