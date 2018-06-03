#!/usr/bin/env bash

# platform-specific config here:
## TODO move into/consolidate with setup.sh
if [ "${BUILD_ARCH}" == "OSX" ]; then

#    these are used in test.sh
    mongo_dir="/usr/local/bin"

elif [ "${BUILD_ARCH}" == "Ubuntu" ]; then
#    export RUBYLIB="/usr/Ruby"
#    export RUBYLIB="/usr/Ruby:$RUBYLIB"
    #    these are used in test.sh
    mongo_dir="/usr/bin"
fi

# run unit tests via openstudio_meta run_rspec command which attempts to reproduce the PAT local environment
# prior to running tests, so we should not set enviroment variables here
if [ "${BUILD_TYPE}" == "test" ];then
    echo "starting unit tests"
    ruby "$BUILD_DIR/bin/openstudio_meta" run_rspec --debug --verbose --mongo-dir="$mongo_dir" "$BUILD_DIR/spec/unit-test"
    exit_status=$?
    if [ $exit_status == 0 ];then
        echo "Completed unit tests successfully"
        exit 0
    fi
#   rspec failed if we made it here:
    echo "Unit tests failed with status $exit_status"
    exit $exit_status
elif [ "${BUILD_TYPE}" == "integration" ]; then
    #    run the analysis integration specs - everything in root directory
    #    use same environment as PAT
    # AP do we need this or is this handled by the openstudio_meta build + start_server and stop_server commands?
    export RAILS_ENV=local
    export SKIP_COVERALLS=true
    #    explicitly set directory.  Probably unnecessary
    cd ./
    echo 'Beginning integration tests'
    bundle exec rspec; (( exit_status = exit_status || $? ))
    exit $exit_status
fi
