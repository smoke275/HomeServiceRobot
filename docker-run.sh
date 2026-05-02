#!/usr/bin/env bash
# docker-run.sh — Launch the ROS Noetic + Gazebo container with X11 forwarding
# and the HomeServiceRobot workspace mounted inside.

set -e

IMAGE_NAME="homeservicerobot-ros-noetic"
CONTAINER_NAME="homeservicerobot"
WORKSPACE_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Build image if it doesn't exist (or pass --build to force rebuild) ──────
if [[ "$1" == "--build" ]] || ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo "[docker-run] Building image: $IMAGE_NAME ..."
    docker build -t "$IMAGE_NAME" "$WORKSPACE_DIR"
fi

# ── Allow local X11 connections from Docker ──────────────────────────────────
xhost +local:docker >/dev/null 2>&1 || true

# ── Remove any stopped container with the same name ─────────────────────────
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "[docker-run] Starting container: $CONTAINER_NAME"

docker run -it \
    --name "$CONTAINER_NAME" \
    --privileged \
    --network host \
    \
    `# X11 forwarding` \
    --env DISPLAY="$DISPLAY" \
    --env QT_X11_NO_MITSHM=1 \
    --env LIBGL_ALWAYS_SOFTWARE=1 \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    \
    `# Mount entire repo as /root/catkin_ws (preserves your src/, build/, devel/)` \
    --volume "$WORKSPACE_DIR:/root/catkin_ws" \
    \
    `# Optional GPU passthrough (remove if no NVIDIA GPU / no nvidia-docker)` \
    $(docker info 2>/dev/null | grep -q "Runtimes.*nvidia" && echo "--gpus all" || true) \
    \
    "$IMAGE_NAME" \
    bash -c "
        source /opt/ros/noetic/setup.bash
        cd /root/catkin_ws
        # Build workspace on first run (or if src changed)
        if [ ! -f devel/setup.bash ]; then
            echo '[docker-run] Building catkin workspace...'
            catkin_make
        fi
        source devel/setup.bash
        echo '[docker-run] ROS Noetic + Gazebo ready. Try: roslaunch turtlebot_gazebo turtlebot_world.launch'
        exec bash --login
    "
