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
        # Jrl-cmake dependencies
        doxygen \
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
        robotpkg-qt5-qgv \
        # Crocoddyl cost plotter dependencies
        python3-grpcio \
        libgrpc++-dev \
        protobuf-compiler-grpc \
        qt6-base-dev \
        grpc-proto \
        # killall
        psmisc \
        # Install the dependency of the ft sensor
        libasio-dev \
        libcurlpp-dev \
    && python -m pip install -U \
        grpcio-tools

# Install all dependencies up to Crocoddyl system-wise
WORKDIR /home/gepetto/dependencies
ADD install_dependency.sh /home/gepetto/dependencies/install_dependency.sh
RUN bash install_dependency.sh stack-of-tasks/eigenpy/v3.10.2/${nthreads} \
    && bash install_dependency.sh coal-library/coal/v3.0.1/${nthreads} \
    && bash install_dependency.sh stack-of-tasks/pinocchio/v3.4.0/${nthreads} \
    && bash install_dependency.sh gepetto/example-robot-data/v4.3.0/${nthreads} \
    # Use devel branch to make OpenMP CMake be found by Crocoddyl
    && bash install_dependency.sh loco-3d/crocoddyl/v3.0.1/${nthreads} \
    && bash install_dependency.sh machines-in-motion/mim_solvers/v0.1.0/${nthreads} \
    && bash install_dependency.sh machines-in-motion/force_feedback_mpc/main/${nthreads} \
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
    # Crocoddyl cost plotter
    && bash install_dependency.sh MaximilienNaveau/crocoddyl_plotter/main/${nthreads} \
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
WORKDIR /home/gepetto/agimus_deps_ws
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && mkdir src \
    # Clone required repositories
    && git clone --branch humble-devel --depth 1 https://github.com/agimus-project/agimus-demos.git src/agimus-demos \
    && vcs import --shallow --recursive src < src/agimus-demos/franka.repos \
    && vcs import --shallow --recursive src < src/agimus-demos/agimus_dev.repos \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i \
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
        --skip-keys gepetto-viewer \
        --skip-keys hpp-gepetto \
        --skip-keys hpp-plot \
        --skip-keys hpp-gui \
        --skip-keys hpp-bin-picking \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
    # Remove unused folders
    && rm -rf build log src

# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/ros2_ws

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/agimus_deps_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc
