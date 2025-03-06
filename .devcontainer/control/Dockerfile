ARG AGIMUS_DOCKER_BASE_IMAGE=gitlab.laas.fr:4567/agimus-project/agimus_dev_container:humble-devel-base
FROM $AGIMUS_DOCKER_BASE_IMAGE
ARG nthreads=1

# Install required packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && sudo apt-get install -qqy --no-install-recommends \
        # ROS 2 dependencies
        ros-$ROS_DISTRO-ros-gz \
        ros-$ROS_DISTRO-pal-statistics* \
        # Crocoddyl dependencies
        coinor-libipopt-dev \
        libassimp-dev \
        libboost-all-dev \
        libeigen3-dev \
        liboctomap-dev \
        libqhull-dev \
        libtinyxml-dev \
        liburdfdom-dev \
        # ProxSuite dependencies
        libsimde-dev \
        libmatio-dev \
        # HPP dependencies
        libomniorb4-dev \
        robotpkg-collada-dom \
        robotpkg-omniorb \
        robotpkg-openscenegraph \
        robotpkg-py310-omniorbpy \
        robotpkg-qpoases \
        robotpkg-qt5-osgqt \
        robotpkg-qt5-qgv

# Install all dependencies up to Crocoddyl system-wise
WORKDIR /home/gepetto/dependencies
ADD install_dependency.sh /home/gepetto/dependencies/install_dependency.sh
RUN bash install_dependency.sh stack-of-tasks/eigenpy/v3.10.0/${nthreads} \
    && bash install_dependency.sh coal-library/coal/v3.0.0/${nthreads} \
    && bash install_dependency.sh stack-of-tasks/pinocchio/v3.3.0/${nthreads} \
    && bash install_dependency.sh gepetto/example-robot-data/v4.1.0/${nthreads} \
    # Use devel branch to make OpenMP CMake be found by Crocoddyl
    && bash install_dependency.sh loco-3d/crocoddyl/devel/${nthreads} \
    && bash install_dependency.sh machines-in-motion/mim_solvers/devel/${nthreads} \
    && bash install_dependency.sh agimus-project/colmpc/main/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-util/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-template-corba/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-statistics/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-environments/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-pinocchio/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-constraints/v6.0.0/${nthreads} \
    # For some reason without `sudo` ProxSuite doesn't find nanobind
    && sudo bash install_dependency.sh Simple-Robotics/proxsuite/devel/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-core/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-corbaserver/v6.0.0/1 \
    && bash install_dependency.sh humanoid-path-planner/hpp-manipulation/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-manipulation-urdf/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-manipulation-corba/v6.0.0/1 \
    && bash install_dependency.sh humanoid-path-planner/gepetto-viewer/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/gepetto-viewer-corba/v6.0.0/1 \
    && bash install_dependency.sh humanoid-path-planner/hpp-gepetto-viewer/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-plot/v6.0.0/${nthreads} \
    && bash install_dependency.sh humanoid-path-planner/hpp-gui/v6.0.0/${nthreads} \
    && bash install_dependency.sh florent-lamiraux/hpp-bin-picking/devel/${nthreads} \
    # Remove folders with meshes and binary data to reduce image size
    && rm -rf example-robot-data \
    && rm -rf pinocchio/models \
    # ProxSuite files require `sudo` to be removed
    && sudo rm -rf proxsuite/test/data

ENV PATH=/usr/local/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
ENV PYTHONPATH=/usr/local/lib/python3.10/site-packages:${PYTHONPATH}
ENV CMAKE_PREFIX_PATH=/usr/local:${CMAKE_PREFIX_PATH}
ENV AMENT_PREFIX_PATH=/usr/local

# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/franka_deps_ws
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && mkdir src \
    # Clone required repositories
    && git clone -b humble --recursive https://github.com/agimus-project/libfranka.git src/libfranka \
    && git clone -b humble-devel https://github.com/agimus-project/franka_description.git src/franka_description \
    && git clone -b humble https://github.com/agimus-project/franka_ros2.git src/franka_ros2 \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
    # Remove unused folders
    && rm -rf build log src

# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/ros2_ws

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/franka_deps_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc
