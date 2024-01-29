#!/bin/bash
set -e

cd /home/gepetto/ros2_ws

colcon build \
        --symlink-install \
        --parallel-workers $(nproc) \
        --cmake-args \
            "-DCMAKE_BUILD_TYPE=Release" \
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=On" \
        -Wall -Wextra -Wpedantic
