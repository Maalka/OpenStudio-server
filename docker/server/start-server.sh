#!/usr/bin/env bash

# Always create new indexes in case the models have changed
cd /opt/openstudio/server && bundle exec rake db:mongoid:create_indexes

ruby /usr/local/lib/memfix-controller.rb start

# AP hack for now to ensure both resque and nginx/rails are running on web
bundle exec environment resque:work &

/opt/nginx/sbin/nginx
