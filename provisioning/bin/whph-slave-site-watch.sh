#!/bin/bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

cd /home/vagrant/whph-website

# echo "current locale settings:"
# locale

echo "setting locale to en_US.UTF-8"
export LANG=ru_RU.UTF-8
export LANGUAGE=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8
locale

# git submodule init
# git submodule update

# stack build && stack exec site -- watch --port 8001

mkdir -p bin

rsync -avz deploy@myfutures.trade:~/whph-slave-bins/site bin/

bin/site watch --port 8001
