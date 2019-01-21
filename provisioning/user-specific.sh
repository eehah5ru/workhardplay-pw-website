#!/bin/bash

cp /vagrant/resources/zshrc ~vagrant/.zshrc
cp /vagrant/resources/ssh-config ~vagrant/.ssh/config

# generate ssh key
#
echo "check ssh key"
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "generating ssh key"
    ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
fi

# install zsh
if [ ! -e /home/vagrant/.oh-my-zsh ]; then
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

# install rvm
if [ ! -e /home/vagrant/.rvm ]; then
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s $1
fi

# install nvm
if [ ! -e /home/vagrant/.nvm ]; then
    mkdir -p /home/vagrant/.nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
fi

# install cabal-install
stack install --resolver lts-9.21 cabal-install
