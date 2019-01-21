#!/bin/bash

set -xe
export PATH=/usr/local/bin:$PATH

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y net-tools wget zlib1g-dev ruby-dev libgmp-dev lsb-release ca-certificates libtinfo-dev unzip zsh curl exiftool imagemagick


sudo chsh -s `which zsh` vagrant

# install stack
if ! which stack; then
    wget -q -O get_stack.sh http://get.haskellstack.org/
    chmod +x get_stack.sh
    ./get_stack.sh
fi

locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
locale-gen ru_RU.UTF-8 


