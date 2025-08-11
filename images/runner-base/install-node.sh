#!/bin/bash
set -xe

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get -y install nodejs

apt-get -y clean
rm -rf /var/lib/apt/lists/*
