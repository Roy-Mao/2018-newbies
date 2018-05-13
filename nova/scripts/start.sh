#!/bin/bash

set -e

eval "$(rbenv init -)"

cd /var/nova/current
export RAILS_ENV=production
mkdir -p tmp/pids
bundle exec puma -d -e production -C config/puma.rb
