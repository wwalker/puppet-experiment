#!/bin/bash

VERSION=0.2.0
ARCH=x86_64
#ARCH=`uname -m`

./build-rpm-vault.sh "${VERSION}" "${ARCH}"
cp ./target/*.rpm /var/www/html/repo

cd /var/www/html/repo
createrepo --update .
