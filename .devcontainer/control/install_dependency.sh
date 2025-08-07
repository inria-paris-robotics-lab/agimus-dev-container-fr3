#!/bin/bash

set -eux

CMAKE_PREFIX_PATH=${1:--$PWD/install}

export CMAKE_PREFIX_PATH

IFS="/" read -r -a split <<< "$1"
ORG="${split[0]}"
PRJ="${split[1]}"
TAG="${split[2]}"
CORES="${split[3]}"

mkdir -p /home/gepetto/dependencies/log
git clone --branch "$TAG" --recursive --depth 1 "https://github.com/$ORG/$PRJ"
cmake -B "$PRJ/build" -S "$PRJ" \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DPYTHON_SITELIB=/usr/local/lib/python3.10/site-packages \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DPYTHON_STANDARD_LAYOUT=OFF \
    -DPYTHON_DEB_LAYOUT=OFF \
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
    -DPROJECT_USE_QT4=OFF \
    -DUSE_QPOASES=OFF \
    -DBUILD_WITH_MULTITHREADS=ON \
    -DBUILD_WITH_VECTORIZATION_SUPPORT=ON \
    -Wno-dev > /home/gepetto/dependencies/log/$PRJ.cmake.log 2>&1
cmake --build "$PRJ/build" -j $CORES > /home/gepetto/dependencies/log/$PRJ.build.log 2>&1
sudo cmake --build "$PRJ/build" -t install > /home/gepetto/dependencies/log/$PRJ.install.log 2>&1
sudo rm -rf "$PRJ/build" "$PRJ/cmake"
