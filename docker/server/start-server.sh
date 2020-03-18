#!/usr/bin/env bash

# noWait argument is added for kubernetes deployments

noWait=0

while [ "$1" != "" ]; do
    case $1 in
        -n | --no-wait )        shift
                                noWait=1
                                ;;
    esac
    shift
done




if [ "$noWait" = "0" ]; then 
    echo "Waiting for Mongo to start"
    /usr/local/bin/wait-for-it --strict -t 0 db:27017

    echo "Waiting for Redis to start"
    /usr/local/bin/wait-for-it --strict -t 0 queue:6379
fi;

# Always create new indexes in case the models have changed
cd /opt/openstudio/server && bundle exec rake db:mongoid:create_indexes

# The memfix-controller seems to have causes some issues with NRCan, need to revisit.
# https://github.com/NREL/OpenStudio-server/issues/348
#ruby /usr/local/lib/memfix-controller.rb start

# AP hack for now to ensure both resque and nginx/rails are running on web.
# Note that this will only run the analysis background queue as it is set in the docker-compose env file.
bundle exec rake environment resque:work &

/opt/nginx/sbin/nginx
