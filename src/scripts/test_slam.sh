#!/bin/sh
CATKIN_WS="$(cd "$(dirname "$0")/../.." && pwd)"

# Create a 3x speed world file for faster SLAM (does not modify the original)
SLAM_WORLD=/tmp/perfect_slam.world
sed 's|<real_time_update_rate>1000</real_time_update_rate>|<real_time_update_rate>4000</real_time_update_rate>|' $CATKIN_WS/src/map/perfect.world > $SLAM_WORLD

# 1. Spawn turtlebot into the running Gazebo world
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; export ROBOT_INITIAL_POSE='-x -0.170228 -y -0.713815 -z 0.0'; roslaunch turtlebot_gazebo turtlebot_world.launch world_file:=/tmp/perfect_slam.world" &
sleep 5

# 2. Launch SLAM gmapping
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; export TURTLEBOT_3D_SENSOR=kinect; roslaunch turtlebot_gazebo gmapping_demo.launch" &
sleep 5

# 3. Launch keyboard teleop to manually drive the robot
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; roslaunch turtlebot_teleop keyboard_teleop.launch" &
sleep 5

# 4. Launch RViz with the navigation/map view
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; roslaunch turtlebot_rviz_launchers view_navigation.launch"
