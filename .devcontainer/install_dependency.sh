#!/bin/bash -eux

CMAKE_PREFIX_PATH=${1:-$PWD/install}

export CMAKE_PREFIX_PATH

IFS="/" read -r -a split <<< "$1"
ORG="${split[0]}"
PRJ="${split[1]}"
TAG="${split[2]}"
CORES="${split[3]}"

git clone --branch "$TAG" --recursive "https://github.com/$ORG/$PRJ"
cmake -B "$PRJ/build" -S "$PRJ" ${CMAKE_FLAGS} -Wno-dev
cmake --build "$PRJ/build" -j $CORES
sudo cmake --build "$PRJ/build" -t install
