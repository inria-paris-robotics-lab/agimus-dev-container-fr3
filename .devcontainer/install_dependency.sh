#!/bin/bash -eux

CMAKE_PREFIX_PATH=${1:-$PWD/install}

export CMAKE_PREFIX_PATH

IFS="/" read -r -a split <<< "$1"
ORG="${split[0]}"
PRJ="${split[1]}"
TAG="${split[2]}"
CORES="${split[3]}"

git clone --branch "$TAG" --depth 1 "https://github.com/$ORG/$PRJ"
cmake -B "$PRJ/build" -S "$PRJ" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTING=OFF \
    -DBUILD_BENCHMARK=OFF \
    -DBUILD_BENCHMARKS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DINSTALL_DOCUMENTATION=OFF \
    -DBUILD_PYTHON_INTERFACE=ON \
    -DGENERATE_PYTHON_STUBS=OFF \
    -DCOAL_BACKWARD_COMPATIBILITY_WITH_HPP_FCL=ON \
    -DCOAL_HAS_QHULL=ON \
    -DBUILD_WITH_COLLISION_SUPPORT=ON \
    -Wno-dev
cmake --build "$PRJ/build" -j $CORES
sudo cmake --build "$PRJ/build" -t install
