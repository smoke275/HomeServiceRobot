# ROS Noetic + Gazebo 11 (Ubuntu 20.04)
# Base image includes: ROS Noetic desktop-full, Gazebo 11, RViz, rqt
FROM osrf/ros:noetic-desktop-full

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install navigation stack, AMCL, map-server, teleop, and other useful tools
RUN apt-get update && apt-get install -y \
    ros-noetic-navigation \
    ros-noetic-amcl \
    ros-noetic-map-server \
    ros-noetic-move-base \
    ros-noetic-slam-gmapping \
    ros-noetic-teleop-twist-keyboard \
    ros-noetic-xacro \
    ros-noetic-robot-state-publisher \
    ros-noetic-joint-state-publisher \
    ros-noetic-joint-state-publisher-gui \
    ros-noetic-gazebo-ros \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-gazebo-plugins \
    ros-noetic-gazebo-ros-control \
    ros-noetic-controller-manager \
    ros-noetic-diff-drive-controller \
    ros-noetic-robot-localization \
    ros-noetic-rtabmap-ros \
    # pgm_map_creator dependencies
    libprotobuf-dev \
    protobuf-compiler \
    libignition-math4-dev \
    # General build tools
    python3-catkin-tools \
    python3-pip \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create catkin workspace
ENV CATKIN_WS=/catkin_ws
RUN mkdir -p ${CATKIN_WS}/src

# Copy workspace source into image (optional – docker-run.sh mounts it instead)
# Kept here so the image can also be used standalone with docker build + run

# Set up ROS environment in bashrc
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc && \
    echo "[ -f ${CATKIN_WS}/devel/setup.bash ] && source ${CATKIN_WS}/devel/setup.bash" >> /root/.bashrc

# Allow X11 forwarding
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
ENV DISABLE_ROS1_EOL_WARNINGS=1

WORKDIR ${CATKIN_WS}

# Default: drop into a bash shell with ROS sourced
CMD ["/bin/bash", "--login"]
