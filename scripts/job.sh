#!/bin/bash

if [[ $TRAVIS_OS_NAME = 'osx' ]]; then
  # What to do in macOS
elif [[ $TRAVIS_OS_NAME = 'linux' ]]; then
  # What to do in Ubunutu
  export PATH="${PWD}/swift-5.6-RELEASE-ubuntu18.04/usr/bin:$PATH"
fi

swift build
swift test
