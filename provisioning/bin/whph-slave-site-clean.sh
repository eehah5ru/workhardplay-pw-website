#!/bin/bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

cd /home/vagrant/whph-website

# git submodule init
# git submodule update

# stack build && stack exec site -- watch --port 8001

rvm . do bundle install

mkdir -p bin

rsync -avz deploy@myfutures.trade:~/whph-slave-bins/site bin/

bin/site clean
