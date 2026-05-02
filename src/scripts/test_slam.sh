#!/bin/sh

# Assumes Gazebo is already running with perfect.world via launch.sh

# 1. Spawn turtlebot into the running Gazebo world
xterm -e "source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash; export ROBOT_INITIAL_POSE='-x -0.170228 -y -0.713815 -z 0.0'; roslaunch turtlebot_gazebo turtlebot_world.launch world_file:=/root/catkin_ws/src/map/perfect.world" &
sleep 5

# 2. Launch SLAM gmapping
xterm -e "source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash; export TURTLEBOT_3D_SENSOR=kinect; roslaunch turtlebot_gazebo gmapping_demo.launch" &
sleep 5

# 3. Launch keyboard teleop to manually drive the robot
xterm -e "source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash; roslaunch turtlebot_teleop keyboard_teleop.launch" &
sleep 5

# 4. Launch RViz with the navigation/map view
xterm -e "source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash; roslaunch turtlebot_rviz_launchers view_navigation.launch"
