#!/bin/sh

# Cartographer SLAM — manual teleop version (replaces test_slam.sh)
# For autonomous frontier exploration use auto_cartographer.sh
# Original gmapping test_slam.sh is untouched

CATKIN_WS="$(cd "$(dirname "$0")/../.." && pwd)"
export CATKIN_WS
FILTER='grep -v -e TF_REPEATED_DATA -e buffer_core.cpp'
SETUP="source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash"

# Create a 3x speed world file for faster SLAM (does not modify the original)
sed 's|<real_time_update_rate>1000</real_time_update_rate>|<real_time_update_rate>3000</real_time_update_rate>|' $CATKIN_WS/src/map/perfect.world > /tmp/perfect_slam.world

# 1. Spawn turtlebot into Gazebo world
xterm -e "bash -c '$SETUP; export ROBOT_INITIAL_POSE=\"-x -0.170228 -y -0.713815 -z 0.0\"; roslaunch turtlebot_gazebo turtlebot_world.launch world_file:=/tmp/perfect_slam.world 2>&1 | $FILTER; exec bash'" &
sleep 15

# 2. Launch Cartographer SLAM
xterm -e "bash -c '$SETUP; export TURTLEBOT_3D_SENSOR=kinect; roslaunch $CATKIN_WS/src/scripts/cartographer_demo.launch 2>&1 | $FILTER; exec bash'" &
sleep 8

# 3. Launch keyboard teleop to manually drive the robot
xterm -e "bash -c '$SETUP; roslaunch turtlebot_teleop keyboard_teleop.launch; exec bash'" &
sleep 5

# 4. Launch RViz with navigation view
xterm -e "bash -c '$SETUP; roslaunch turtlebot_rviz_launchers view_navigation.launch 2>&1 | $FILTER; exec bash'"

# When mapping is done, save the map with:
#   rosrun map_server map_saver -f $CATKIN_WS/src/map/my_map1
