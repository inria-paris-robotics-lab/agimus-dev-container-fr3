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
WORKDIR /home/gepetto/ros2_ws

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/ignition/setup.sh" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc
