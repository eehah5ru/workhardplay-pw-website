#!/bin/bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 

cd /home/vagrant/whph-website

git submodule init
git submodule update

rvm . do bundle install

dist_dir=`stack path | grep "^dist-dir:" | awk -F ': ' '{print $2}' `

(rvm . do rake stack:build) && rsync -avz $dist_dir/build/site/site deploy@myfutures.trade:~/whph-slave-bins/
