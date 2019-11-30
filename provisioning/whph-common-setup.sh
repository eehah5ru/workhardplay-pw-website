#!/bin/bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

rvm install `cat /home/vagrant/whph-website/.ruby-version`

cd /home/vagrant/whph-website

rvm . do gem install bundler

rvm . do bundle install

nvm install `cat .nvmrc`

nvm use

rm -rf node_modules

npm install

# FIXME: nothing saved in bower.json
npx bower install
