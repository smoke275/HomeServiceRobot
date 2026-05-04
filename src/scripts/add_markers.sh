#!/bin/sh
CATKIN_WS="$(cd "$(dirname "$0")/../.." && pwd)"

# 1. Spawn turtlebot into Gazebo world
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; export ROBOT_INITIAL_POSE='-x -0.170228 -y -0.713815 -z 0.0'; roslaunch turtlebot_gazebo turtlebot_world.launch world_file:=$CATKIN_WS/src/map/perfect.world" &
sleep 15

# 2. Launch AMCL for localization with saved map
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; export TURTLEBOT_3D_SENSOR=kinect; roslaunch turtlebot_gazebo amcl_demo.launch map_file:=$CATKIN_WS/src/map/my_map1.yaml initial_pose_x:=-0.170228 initial_pose_y:=-0.713815 initial_pose_a:=0.0" &
sleep 5

# 3. Launch RViz with navigation view
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; roslaunch turtlebot_rviz_launchers view_navigation.launch" &
sleep 5

# 4. Run the add_markers node
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; rosrun add_markers add_markers"
