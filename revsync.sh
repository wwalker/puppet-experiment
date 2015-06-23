#!/bin/bash

set -e -o pipefail

rsync -avx -e ssh --delete root@puppet.lxc:/etc/puppet/ ./puppet-master/
