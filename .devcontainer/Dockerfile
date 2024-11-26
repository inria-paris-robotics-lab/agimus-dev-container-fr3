FROM osrf/ros:humble-desktop

SHELL ["/bin/bash", "-c"]

ENV RCUTILS_COLORIZED_OUTPUT=1

# Install required packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -qqy --no-install-recommends \
        # general dependencies
        bash-completion \
        build-essential \
        clang \
        clang-format \
        cmake \
        ninja-build \
        gdb \
        git \
        htop \
        nano \
        iputils-ping \
        net-tools \
        sudo \
        wget \
        vim \
        unzip \
        # libfranka dependencies
        libpoco-dev \
        libeigen3-dev \
        # python dependencies
        python-is-python3 \
        python3-flake8 \
        python3-pip \
        python3-setuptools \
        # ros dependencies
        ros-$ROS_DISTRO-rmw-fastrtps-cpp \
        ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
        ros-$ROS_DISTRO-plotjuggler \
        ros-$ROS_DISTRO-plotjuggler-ros \
        ros-$ROS_DISTRO-ros-gz \
        ros-dev-tools \
        # Crocoddyl dependencies
        libglfw3 \
        libglfw3-dev \
        coinor-libipopt-dev \
        libassimp-dev \
        libboost-all-dev \
        libeigen3-dev \
        liboctomap-dev \
        libqhull-dev \
        libtinyxml-dev \
        liburdfdom-dev \
        libomp-dev \
        python-is-python3 \
        python3-dev \
        python3-numpy \
        python3-scipy \
    && python -m pip install -U \
        argcomplete \
        pre-commit
# Add robotpkg dependency
RUN mkdir -p /etc/apt/keyrings \
    && curl http://robotpkg.openrobots.org/packages/debian/robotpkg.asc \
    | tee /etc/apt/keyrings/robotpkg.asc \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/robotpkg.asc] http://robotpkg.openrobots.org/packages/debian/pub $(lsb_release -cs) robotpkg" \
    | tee /etc/apt/sources.list.d/robotpkg.list

ENV PATH=/opt/openrobots/bin:${PATH}
ENV PKG_CONFIG_PATH=/opt/openrobots/lib/pkgconfig:${PKG_CONFIG_PATH}
ENV LD_LIBRARY_PATH=/opt/openrobots/lib:${LD_LIBRARY_PATH}
ENV PYTHONPATH=/opt/openrobots/lib/python3.10/site-packages:${PYTHONPATH}
ENV CMAKE_PREFIX_PATH=/opt/openrobots:${CMAKE_PREFIX_PATH}

# Build libfranka
RUN git clone -b active-control-backport --recursive https://github.com/tingelst/libfranka \
    && cmake -B build -S libfranka -DBUILD_TESTS=OFF \
    && cmake --build build \
    && cmake --install build \
    && rm -rf libfranka build

# Create the user
RUN groupadd --gid 1000 gepetto \
    && useradd --uid 1000 --gid 1000 -m gepetto \
    && echo gepetto ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/gepetto \
    && chmod 0440 /etc/sudoers.d/gepetto

# Keep bash history when docker is rebuilt
RUN mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R gepetto /commandhistory \
    && echo "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" >> "/home/gepetto/.bashrc"

USER gepetto

# Change compilation defaults to enable a bit more efficient preserving portability
ENV CMAKE_BUILD_TYPE=RelWithDebInfo
ENV CMAKE_CXX_FLAGS="-O3"

# Install all dependencies up to Crocoddyl system-wise
WORKDIR /home/gepetto/dependencies
ADD install_dependency.sh /home/gepetto/dependencies/install_dependency.sh
RUN bash install_dependency.sh stack-of-tasks/eigenpy/v3.10.0/4 \
    && bash install_dependency.sh coal-library/coal/v3.0.0/10 \
    && bash install_dependency.sh stack-of-tasks/pinocchio/v3.3.0/5 \
    && bash install_dependency.sh gepetto/example-robot-data/v4.1.0/10 \
    && bash install_dependency.sh loco-3d/crocoddyl/v2.1.0/10\
    && bash install_dependency.sh machines-in-motion/mim_solvers/devel/10 \
    && bash install_dependency.sh agimus-project/colmpc/main/10 \
    # Remove example-robot-data source to shrink resulting Docker image
    && rm -rf /home/gepetto/dependencies/example-robot-data

# # Install HappyPose and PyM3T
# WORKDIR /tmp
# RUN git clone --branch dev --recurse-submodules https://github.com/agimus-project/happypose.git \
#     && cd happypose \
#     && pip install ".[cpu,pypi,evaluation,multiview]" --extra-index-url https://download.pytorch.org/whl/cpu \
#     && pip install git+https://github.com/agimus-project/pym3t@master

# # Download CosyPose models
# WORKDIR /home/gepetto/happypose_data_dir
# ENV HAPPYPOSE_DATA_DIR=/home/gepetto/happypose_data_dir
# # Download YCBV pretrained models
# RUN python -m happypose.toolbox.utils.download \
#         --bop_dataset ycbv \
#         --cosypose_models  \
#             detector-bop-ycbv-pbr--970850 \
#             coarse-bop-ycbv-pbr--724183 \
#             refiner-bop-ycbv-pbr--604090 \
#             detector-bop-ycbv-synt+real--292971 \
#             coarse-bop-ycbv-synt+real--822463 \
#             refiner-bop-ycbv-synt+real--631598 \
#     && cd $HAPPYPOSE_DATA_DIR/bop_datasets/ycbv \
#     && unzip -n -qq ycbv_base.zip \
#     && unzip -n -qq ycbv_models.zip \
#     && rm *.zip \
#     # Download TLESS pretrained models
#     && python -m happypose.toolbox.utils.download \
#         --bop_dataset tless \
#         --cosypose_models  \
#             detector-bop-tless-pbr--873074 \
#             coarse-bop-tless-pbr--506801 \
#             refiner-bop-tless-pbr--233420 \
#             detector-bop-tless-synt+real--452847 \
#             coarse-bop-tless-synt+real--160982 \
#             refiner-bop-tless-synt+real--881314 \
#     && cd $HAPPYPOSE_DATA_DIR/bop_datasets/tless \
#     && unzip -n -qq tless_base.zip \
#     && unzip -n -qq tless_models.zip \
#     && rm *.zip

# # Install ROS dependencies for vision pipeline
# WORKDIR /home/gepetto/vision_deps_ws
# RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
#     --mount=type=cache,sharing=locked,target=/var/lib/apt \
#     --mount=type=cache,sharing=locked,target=/root/.cache \
#     sudo apt-get update \
#     && mkdir src \
#     && cd src \
#     # Clone required repositories
#     && git clone https://github.com/agimus-project/happypose_ros.git \
#     && git clone https://gitlab.laas.fr/kwojciecho/m3t_tracker_ros.git \
#     && git clone https://gitlab.laas.fr/kwojciecho/olt_ros2_pipeline.git \
#     && git clone https://gitlab.laas.fr/kwojciecho/happypose_marker_publisher.git \
#     && cd .. \
#     # Build packages from source
#     && source /opt/ros/$ROS_DISTRO/setup.bash \
#     && rosdep update --rosdistro $ROS_DISTRO \
#     && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
#     && colcon build \
#           --symlink-install libfranka \
#           --skip-keys eigenpy \
#           --skip-keys hpp-fcl \
#           --skip-keys pinocchio \
#           --skip-keys crocoddyl \
#     # Convert HappyPose models to M3T views
#     && mkdir -p /home/gepetto/m3t_data_dir \
#     && source install/setup.bash \
#     # Create sparse views for YCBV
#     && export M3T_DATA_DIR=/home/gepetto/m3t_data_dir \
#     && ros2 run m3t_tracker_ros prepare_sparse_views \
#         --input-path $HAPPYPOSE_DATA_DIR/bop_datasets/ycbv/models \
#         --output-path $M3T_DATA_DIR \
#         --use-depth \
#     # Create sparse views for TLESS
#     && ros2 run m3t_tracker_ros prepare_sparse_views \
#         --input-path $HAPPYPOSE_DATA_DIR/bop_datasets/tless/models_cad \
#         --output-path $M3T_DATA_DIR \
#         --use-depth
# ENV M3T_DATA_DIR=/home/gepetto/m3t_data_dir


# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/franka_deps_ws
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && mkdir src \
    && cd src \
    # Clone required repositories
    && git clone --branch v0.1.15 https://github.com/frankaemika/franka_ros2.git \
    # Remplace new libfranka version with old one
    && cd franka_ros2 \
    && find . -type f -name 'CMakeLists.txt' | xargs sed -i 's/find_package(Franka 0.13.* REQUIRED)/find_package(Franka 0.9.3 REQUIRED)/' \
    && cd ../.. \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
        --skip-keys libfranka \
        --skip-keys eigenpy \
        --skip-keys hpp-fcl \
        --skip-keys pinocchio \
        --skip-keys crocoddyl \
    && colcon build --symlink-install

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/ros2_ws

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    # && echo "source /home/gepetto/vision_deps_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/franka_deps_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/ignition/setup.sh" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc

# Install HPP
#

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && sudo apt-get upgrade -y \
    && sudo apt-get install -qqy --no-install-recommends \
    robotpkg-collada-dom robotpkg-omniorb robotpkg-openscenegraph \
    robotpkg-py310-omniorbpy robotpkg-py310-ros-catkin \
    robotpkg-qpoases robotpkg-qt5-osgqt

WORKDIR /home/gepetto/dependencies
RUN bash install_dependency.sh humanoid-path-planner/hpp-util/master/1
RUN bash install_dependency.sh humanoid-path-planner/hpp-template-corba/master/1
RUN bash install_dependency.sh humanoid-path-planner/hpp-statistics/master/1
RUN bash install_dependency.sh humanoid-path-planner/hpp-environments/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-pinocchio/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-constraints/master/4
ENV CMAKE_FLAGS="-DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF -DBUILD_BENCHMARK=OFF -DBUILD_BENCHMARKS=OFF -DBUILD_EXAMPLES=OFF -DINSTALL_DOCUMENTATION=OFF -DBUILD_PYTHON_INTERFACE=OFF -DGENERATE_PYTHON_STUBS=OFF -DCOAL_BACKWARD_COMPATIBILITY_WITH_HPP_FCL=ON -DCOAL_HAS_QHULL=ON -DBUILD_WITH_COLLISION_SUPPORT=ON -DPROJECT_USE_QT4=OFF -DUSE_QPOASES=OFF -DBUILD_WITH_VECTORIZATION_SUPPORT=OFF"
ADD install_dependency-1.sh /home/gepetto/dependencies/install_dependency.sh
RUN bash install_dependency.sh Simple-Robotics/proxsuite/v0.6.5/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-core/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-corbaserver/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-manipulation/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-manipulation-urdf/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-manipulation-corba/master/4
RUN bash install_dependency.sh humanoid-path-planner/gepetto-viewer/master/4
RUN bash install_dependency.sh humanoid-path-planner/gepetto-viewer-corba/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-gepetto-viewer/master/4

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && sudo apt-get upgrade -y \
    && sudo apt-get install -qqy --no-install-recommends \
    robotpkg-qt5-qgv
RUN bash install_dependency.sh humanoid-path-planner/hpp-plot/master/4
RUN bash install_dependency.sh humanoid-path-planner/hpp-gui/master/4
RUN bash install_dependency.sh florent-lamiraux/hpp-bin-picking/devel/4
