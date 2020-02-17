#!/bin/bash

set -xe
export PATH=/usr/local/bin:$PATH

export DEBIAN_FRONTEND=noninteractive


echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/base
resolvconf -u

sudo add-apt-repository ppa:eugenesan/ppa -y
sudo add-apt-repository ppa:avsm/ppa -y

apt-get update

apt-get install -y net-tools wget zlib1g-dev ruby-dev libgmp-dev lsb-release ca-certificates libtinfo-dev unzip zsh curl exiftool imagemagick htop libmagickwand-dev

# unison deps
sudo apt-get install -y ocaml camlp4 camlp4-extra opam

# apt-get install unison

sudo chsh -s `which zsh` vagrant

# install stack
if ! which stack; then
    wget -q -O get_stack.sh http://get.haskellstack.org/
    chmod +x get_stack.sh
    ./get_stack.sh
fi

# if ! which unison; then
#     sudo -u vagrant mkdir -p ~vagrant/tmp
#     su vagrant -c "mkdir -p ~vagrant/bin"
#     cd ~vagrant/tmp
#     rm -rf unison-2.51.2
#     sudo -u vagrant wget https://github.com/bcpierce00/unison/archive/v2.51.2.tar.gz
#     sudo -u vagrant tar xzvf v2.51.2.tar.gz
#     cd unison-2.51.2
#     su vagrant -c make
#     su vagrant -c "make install"

#     mkdir -p /usr/local/bin

#     ln -s /home/vagrant/bin/unison /usr/local/bin
# fi

if ! which pandoc; then
    su vagrant -c "mkdir -p ~vagrant/bin"
    cd ~vagrant/tmp
    wget https://github.com/jgm/pandoc/releases/download/2.6/pandoc-2.6-1-amd64.deb
    sudo dpkg -i pandoc-2.6-1-amd64.deb
    rm pandoc-2.6-1-amd64.deb
fi

#
# install imagemagick
#
if ! which convert; then
    apt-get install imagemagick
fi


#
# update locales

locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
locale-gen ru_RU.UTF-8

dpkg-reconfigure locales
