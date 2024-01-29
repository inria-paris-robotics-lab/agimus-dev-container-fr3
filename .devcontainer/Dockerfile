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
        ros-dev-tools \
    && python -m pip install -U \
        argcomplete \
        pre-commit

# Build libfranka
RUN git clone -b 0.9.2 --recursive https://github.com/frankaemika/libfranka \
    && cmake -B build -S libfranka -DBUILD_TESTS=OFF \
    && cmake --build build \
    && cmake --install build \
    && rm -rf libfranka build

# Create the user
RUN groupadd --gid 1000 gepetto \
    && useradd --uid 1000 --gid 1000 -m gepetto \
    && echo gepetto ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/gepetto \
    && chmod 0440 /etc/sudoers.d/gepetto

USER gepetto
WORKDIR /home/gepetto

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/gazebo/setup.sh" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc
