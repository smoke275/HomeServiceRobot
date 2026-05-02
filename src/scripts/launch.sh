#!/bin/sh

xterm -e "source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash; roslaunch gazebo_ros empty_world.launch use_sim_time:=true debug:=false gui:=true world_name:=/root/catkin_ws/src/map/perfect.world" &
sleep 5
xterm -e "source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash; rosrun rviz rviz"
