#!/usr/bin/env bash

# noWait argument is added for kubernetes deployments

noWait=0

while [ "$1" != "" ]; do
    case $1 in
        -n | --no-wait )        shift
                                noWait=1
                                ;;
        * )                     shift
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



# Only start a single worker when calling this script (do not use resque:workers).
cd /opt/openstudio/server && bundle exec rake environment resque:work
