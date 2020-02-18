#!/bin/bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 

cd /home/vagrant/whph-website

# git submodule init
# git submodule update

rvm . do bundle install

(nohup guard &) && (rvm . do rake server:watch) #; (killall -9 guard)
