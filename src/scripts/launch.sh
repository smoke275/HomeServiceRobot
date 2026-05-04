#!/bin/sh
CATKIN_WS="$(cd "$(dirname "$0")/../.." && pwd)"

xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; roslaunch gazebo_ros empty_world.launch use_sim_time:=true debug:=false gui:=true world_name:=$CATKIN_WS/src/map/perfect.world" &
sleep 5
xterm -e "source /opt/ros/noetic/setup.bash; source $CATKIN_WS/devel/setup.bash; rosrun rviz rviz"
