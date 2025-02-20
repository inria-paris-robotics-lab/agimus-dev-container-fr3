ARG AGIMUS_DOCKER_BASE_IMAGE=gitlab.laas.fr:4567/agimus-project/agimus_dev_container:humble-devel-base
FROM $AGIMUS_DOCKER_BASE_IMAGE

# Choose between `cpu` and `cu124`
ARG HAPPYPOSE_INSTALL_TYPE=cpu

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && sudo apt-get install -qqy --no-install-recommends \
        libglfw3 \
        libglfw3-dev

# Install HappyPose and PyM3T
WORKDIR /home/gepetto/vision_deps
RUN git clone --branch dev --recurse-submodules https://github.com/agimus-project/happypose.git \
    && cd happypose \
    && pip install -U pip \
    && pip install -r requirements/pypi.txt -r requirements/$HAPPYPOSE_INSTALL_TYPE.txt \
    && pip install git+https://github.com/agimus-project/pym3t@master

# Download CosyPose models
WORKDIR /home/gepetto/happypose_data_dir
ENV HAPPYPOSE_DATA_DIR=/home/gepetto/happypose_data_dir
# Download YCBV pretrained models
RUN python -m happypose.toolbox.utils.download \
        --bop_dataset ycbv \
        --cosypose_models  \
            detector-bop-ycbv-pbr--970850 \
            coarse-bop-ycbv-pbr--724183 \
            refiner-bop-ycbv-pbr--604090 \
            detector-bop-ycbv-synt+real--292971 \
            coarse-bop-ycbv-synt+real--822463 \
            refiner-bop-ycbv-synt+real--631598 \
    && cd $HAPPYPOSE_DATA_DIR/bop_datasets/ycbv \
    && unzip -n -qq ycbv_base.zip \
    && unzip -n -qq ycbv_models.zip \
    # Remove unused files
    && rm -rf models_eval models_file *.zip \
    # Download TLESS pretrained models
    && python -m happypose.toolbox.utils.download \
        --bop_dataset tless \
        --cosypose_models  \
            detector-bop-tless-pbr--873074 \
            coarse-bop-tless-pbr--506801 \
            refiner-bop-tless-pbr--233420 \
            detector-bop-tless-synt+real--452847 \
            coarse-bop-tless-synt+real--160982 \
            refiner-bop-tless-synt+real--881314 \
    && cd $HAPPYPOSE_DATA_DIR/bop_datasets/tless \
    && unzip -n -qq tless_base.zip \
    && unzip -n -qq tless_models.zip \
    # Remove unused files
    && rm -rf models_eval models_reconst *.zip

ENV M3T_DATA_DIR=/home/gepetto/m3t_data_dir
# Install ROS dependencies for vision pipeline
WORKDIR /home/gepetto/vision_deps_ws
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && mkdir src \
    # Clone required repositories
    && git clone --branch main https://github.com/agimus-project/happypose_ros.git src/happypose_ros \
    && git clone --branch main https://github.com/agimus-project/m3t_tracker_ros.git src/m3t_tracker_ros \
    && git clone --branch main https://github.com/agimus-project/olt_ros2_pipeline.git src/olt_ros2_pipeline \
    && git clone --branch main https://github.com/agimus-project/detection2d_marker_publisher.git src/detection2d_marker_publisher \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
        --skip-keys pinocchio \
        --skip-keys hpp-fcl \
        --skip-keys happypose_marker_publisher \
    && colcon build \
    # Remove unused folders
    && rm -rf build log \
    # Convert HappyPose models to M3T views
    && mkdir -p $M3T_DATA_DIR
# RUN source install/setup.bash \
#     # Create sparse views for YCBV
#     && ros2 run m3t_tracker_ros prepare_sparse_views \
#         --input-path $HAPPYPOSE_DATA_DIR/bop_datasets/ycbv/models \
#         --output-path $M3T_DATA_DIR \
#         --use-depth \
#     # Create sparse views for TLESS
#     && ros2 run m3t_tracker_ros prepare_sparse_views \
#         --input-path $HAPPYPOSE_DATA_DIR/bop_datasets/tless/models_cad \
#         --output-path $M3T_DATA_DIR \
#         --use-depth

# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/franka_deps_ws
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=cache,sharing=locked,target=/root/.cache \
    sudo apt-get update \
    && mkdir src \
    # Clone required repositories
    && git clone --branch humble-devel https://github.com/agimus-project/franka_description.git src/franka_description \
    # Build packages from source
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && rosdep update --rosdistro $ROS_DISTRO \
    && rosdep install -y -i --from-paths src --rosdistro $ROS_DISTRO \
    && colcon build \
    # Remove unused folders
    && rm -rf build log src

# Install ROS dependencies for Franka ROS
WORKDIR /home/gepetto/ros2_ws

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/vision_deps_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/franka_deps_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /home/gepetto/ros2_ws/install/setup.bash" >> /home/gepetto/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/gepetto/.bashrc
