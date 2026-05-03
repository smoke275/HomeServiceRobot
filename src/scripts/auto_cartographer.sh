#!/bin/sh

# Autonomous Cartographer SLAM with frontier exploration
# Uses Cartographer (loop closure) instead of gmapping, plus explore_lite for autonomous driving
# Equivalent to auto_slam.sh but with superior loop closure recovery

FILTER='grep -v -e TF_REPEATED_DATA -e buffer_core.cpp'
SETUP='source /opt/ros/noetic/setup.bash; source /root/catkin_ws/devel/setup.bash'

# Create a 3x speed world file for faster SLAM (does not modify the original)
SLAM_WORLD=/tmp/perfect_slam.world
sed 's|<real_time_update_rate>1000</real_time_update_rate>|<real_time_update_rate>3000</real_time_update_rate>|' /root/catkin_ws/src/map/perfect.world > $SLAM_WORLD

# 1. Spawn TurtleBot2 into Gazebo world
xterm -e "bash -c '$SETUP; export ROBOT_INITIAL_POSE=\"-x -0.170228 -y -0.713815 -z 0.0\"; roslaunch turtlebot_gazebo turtlebot_world.launch world_file:=$SLAM_WORLD 2>&1 | $FILTER; exec bash'" &
sleep 15

# 2. Launch Cartographer SLAM (publishes /map via occupancy_grid_node)
xterm -e "bash -c '$SETUP; export TURTLEBOT_3D_SENSOR=kinect; roslaunch /root/catkin_ws/src/scripts/cartographer_demo.launch 2>&1 | $FILTER; exec bash'" &
sleep 10

# 3. Launch move_base (required for explore_lite to send navigation goals)
xterm -e "bash -c '$SETUP; roslaunch /root/catkin_ws/src/scripts/move_base.launch 2>&1 | $FILTER; exec bash'" &
sleep 5

# 4. Launch RViz to monitor mapping progress
xterm -e "bash -c '$SETUP; roslaunch turtlebot_rviz_launchers view_navigation.launch 2>&1 | $FILTER; exec bash'" &
sleep 5

# 5. Launch frontier exploration (autonomously drives robot to map the environment)
xterm -e "bash -c '$SETUP; roslaunch explore_lite explore.launch costmap_topic:=/map costmap_updates_topic:=/map_updates visualize:=true planner_frequency:=0.5 progress_timeout:=30.0 min_frontier_size:=0.3 2>&1 | $FILTER; exec bash'"

# When mapping is complete, save the map with:
#   rosrun map_server map_saver -f /root/catkin_ws/src/map/my_map
