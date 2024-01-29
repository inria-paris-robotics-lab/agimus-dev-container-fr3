#!/bin/bash -e

cd /home/gepetto/ros2_ws

sudo apt update
# Modify if .repos files exist
# vcs import < src/project.repos src
rosdep update --rosdistro $ROS_DISTRO
rosdep install -y -i \
    --from-paths src \
    --rosdistro $ROS_DISTRO \
    --skip-keys libfranka
