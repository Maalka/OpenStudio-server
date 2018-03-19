#!/bin/bash -x

echo "The build architecture is ${BUILD_ARCH}"
if [ "${BUILD_ARCH}" == "OSX" ]; then
    mkdir /Users/travis/build/NREL/OpenStudio-server/spec/files/logs
    brew update > /Users/travis/build/NREL/OpenStudio-server/spec/files/logs/brew-update.log
    brew install mongodb@3.4
    ln -s /usr/local/opt/mongodb@3.4/bin/* /usr/local/bin
    unset BUNDLE_GEMFILE

    curl -SLO https://openstudio-resources.s3.amazonaws.com/pat-dependencies/OpenStudio-2.0.3.40f61c64a3-darwin.zip
    mkdir ~/openstudio
    unzip OpenStudio-2.0.3.40f61c64a3-darwin.zip -d ~/openstudio
    mv ~/openstudio/openstudio-2.0.3/* ~/openstudio/
    export RUBYLIB="${HOME}/openstudio/Ruby/:$RUBYLIB"
    ruby ./bin/openstudio_meta install_gems --with_test_develop --debug --verbose --use_cached_gems
elif [ "${BUILD_ARCH}" == "Ubuntu" ]; then
    echo "Setting up Ubuntu for unit tests and Rubocop"
    mkdir -p reports/rspec

    # If not running on travis, then to install MongoDB and Ruby, run the following:
#    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
#    echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
#    sudo apt-get update
#    sudo mkdir -p /data/db
#    sudo apt-get install -y mongodb-org
#    ./docker/deployment/scripts/install_ruby.sh 2.2.4 b6eff568b48e0fda76e5a36333175df049b204e91217aa32a65153cc0cdcb761

    ./docker/deployment/scripts/install_openstudio.sh 2.4.0 f58a3e1808
    export RUBYLIB="/usr/Ruby:$RUBYLIB"
    if [ "${BUILD_TYPE}" == "test" ]; then
        echo "In test mode"
        export BUNDLE_GEMFILE=./server/Gemfile
        bundle install --with=test develop
    elif [ "${BUILD_TYPE}" == "integration" ]; then
        # If we are running integration tests, then we need to get the openstudio_meta install_gems working
        ruby ./bin/openstudio_meta install_gems --with_test_develop --debug --verbose --use_cached_gems
    fi
elif [ "${BUILD_ARCH}" == "RedHat" ]; then
	docker pull nrel/openstudio-server-hpc
	CONTAINER_ID=$(mktemp)
	docker run --detach --volume="${PWD}":/root/openstudio-server ${RUN_OPTS} nrel/openstudio-server-hpc "/usr/lib/systemd/systemd" > "${CONTAINER_ID}"
	docker exec --tty "$(cat ${CONTAINER_ID})" env TERM=xterm ruby ~/openstudio-server/bin/openstudio_meta install_gems --with_test_develop --debug --verbose
fi
