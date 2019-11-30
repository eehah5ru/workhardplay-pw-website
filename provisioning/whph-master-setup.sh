#!/bin/bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# install cabal-install
stack install --resolver lts-9.21 cabal-install

cd /home/vagrant/whph-website

#
# stack part
#

rm stack.yaml
ln -s stack.yaml.linux stack.yaml

# stack install cabal-install
stack setup

