#!/bin/bash

if [[ $TRAVIS_OS_NAME = 'osx' ]]; then
  # install macOS prerequistes
elif [[ $TRAVIS_OS_NAME = 'linux' ]]; then
  # download swift
  wget https://swift.org/builds/swift-5.6-release/ubuntu1804/swift-5.6-RELEASE/swift-5.6-RELEASE-ubuntu18.04.tar.gz
  # extract the archive
  tar xzf swift-5.6-RELEASE-ubuntu18.04.tar.gz
  # include the swift command in the PATH
  export PATH="${PWD}/swift-5.6-RELEASE-ubuntu18.04/usr/bin:$PATH"
fi
