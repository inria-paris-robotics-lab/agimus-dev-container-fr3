#!/bin/bash -e

cd /home/gepetto/ros2_ws

sudo apt update
# Modify if .repos files exist
# vcs import < src/project.repos src
rosdep update --rosdistro $ROS_DISTRO
rosdep install -y -i \
    --from-paths src \
    --rosdistro $ROS_DISTRO \
    --skip-keys libfranka \
    --skip-keys eigenpy \
    --skip-keys hpp-fcl \
    --skip-keys coal \
    --skip-keys pinocchio \
    --skip-keys crocoddyl \
    --skip-keys mim_solvers \
    --skip-keys colmpc \
    --skip-keys hpp-util \
    --skip-keys hpp-template \
    --skip-keys hpp-statistics \
    --skip-keys hpp-environments \
    --skip-keys hpp-pinocchio \
    --skip-keys hpp-constraints \
    --skip-keys proxsuite \
    --skip-keys hpp-core \
    --skip-keys hpp-corbaserver \
    --skip-keys hpp-manipulation \
    --skip-keys hpp-manipulation \
    --skip-keys hpp-manipulation \
    --skip-keys gepetto-viewer \
    --skip-keys gepetto-viewer \
    --skip-keys hpp-gepetto \
    --skip-keys hpp-plot \
    --skip-keys hpp-gui \
    --skip-keys hpp-bin-picking
