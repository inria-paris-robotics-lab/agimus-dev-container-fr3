FROM osrf/ros:humble-desktop

SHELL ["/bin/bash", "-c"]

ENV RCUTILS_COLORIZED_OUTPUT=1
ENV CMAKE_BUILD_TYPE=RelWithDebInfo


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
    && python -m pip install -U \
        argcomplete \
        pre-commit

# Set default compiler to Clang
ENV CXX=clang++
ENV CC=clang

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

# Install ROS dependencies for control
WORKDIR /home/gepetto/control_deps
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    apt-get update \
    && mkdir src \
    && cd src \
    # Clone required repositories
    && git clone --branch v3.10.1 --recursive https://github.com/stack-of-tasks/eigenpy.git \
    && git clone --branch v3.0.0 --recursive https://github.com/coal-library/coal.git \
    && git clone --branch v3.3.0 --recursive https://github.com/stack-of-tasks/pinocchio.git \
    && git clone --branch v2.1.0 --recursive https://github.com/loco-3d/crocoddyl.git \
    && git clone --branch v4.1.0 --recursive https://github.com/Gepetto/example-robot-data.git \
    && git clone --branch devel --recursive https://github.com/machines-in-motion/mim_solvers.git \
    && git clone --branch main --recursive https://github.com/agimus-project/colmpc.git \
    && cd .. \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
    && colcon build \
        --cmake-args \
            -DBUILD_TESTING=OFF \
            -DBUILD_BENCHMARK=OFF \
            -DBUILD_BENCHMARKS=OFF \
            -DBUILD_EXAMPLES=OFF \
            -DINSTALL_DOCUMENTATION=OFF \
            -DBUILD_PYTHON_INTERFACE=ON \
            -DGENERATE_PYTHON_STUBS=OFF \
            -DPYTHON_EXECUTABLE=/usr/bin/python \
            -DPYTHON_SITELIB=lib/python3/dist-packages \
            -DCOAL_HAS_QHULL=ON \
            -DBUILD_WITH_SDF_SUPPORT=ON \
            -BUILD_WITH_COLLISION_SUPPORT=ON \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DCMAKE_CXX_FLAGS="-O3"


# Install HappyPose and PyM3T and download CosyPose models
WORKDIR /home/gepetto/happypose_data_dir
ENV HAPPYPOSE_DATA_DIR=/home/gepetto/happypose_data_dir
RUN pip install git+https://github.com/agimus-project/pym3t@master \
    && pip install git+https://github.com/agimus-project/happypose.git@uv\
    # Download YCBV pretrained models
    && python -m happypose.toolbox.utils.download \
        --bop_dataset ycbv \
        --cosypose_models  \
            detector-bop-ycbv-pbr--970850 \
            coarse-bop-ycbv-pbr--724183 \
            refiner-bop-ycbv-pbr--604090 \
    && cd $HAPPYPOSE_DATA_DIR/bop_datasets/ycbv \
    && unzip -n -qq ycbv_base.zip \
    && unzip -n -qq ycbv_models.zip \
    # Download TLESS pretrained models
    && python -m happypose.toolbox.utils.download \
        --bop_dataset tless \
        --cosypose_models  \
            detector-bop-tless-pbr--873074 \
            coarse-bop-tless-pbr--506801 \
            refiner-bop-tless-pbr--233420 \
    && cd $HAPPYPOSE_DATA_DIR/bop_datasets/tless \
    && unzip -n -qq tless_base.zip \
    && unzip -n -qq tless_models_cad.zip

# Install ROS dependencies for vision pipeline
WORKDIR /home/gepetto/vision_deps
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    apt-get update \
    && mkdir src \
    && cd src \
    # Clone required repositories
    && git clone https://github.com/agimus-project/happypose_ros.git \
    && git clone https://gitlab.laas.fr/kwojciecho/m3t_tracker_ros.git \
    && git clone https://gitlab.laas.fr/kwojciecho/olt_ros2_pipeline.git \
    && git clone https://gitlab.laas.fr/kwojciecho/happypose_marker_publisher.git \
    && cd .. \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
    && colcon build --symlink-install \
    # Convert HappyPose models to M3T views
    && mkdir -p /home/gepetto/m3t_data_dir \
    && source /home/gepetto/control_deps/install/setup.bash \
    # Create sparse views for YCBV
    && ros2 run m3t_tracker_ros prepare_sparse_views \
        --input-path $HAPPYPOSE_DATA_DIR/bop_datasets/ycbv/models \
        --output-path /tmp/m3t_data_dir \
        --use-depth \
    # Create sparse views for TLESS
    && ros2 run m3t_tracker_ros prepare_sparse_views \
        --input-path $HAPPYPOSE_DATA_DIR/bop_datasets/tless/models_cad \
        --output-path /tmp/m3t_data_dir \
        --use-depth



ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/control_deps/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/vision_deps/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/ignition/setup.sh" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc
