# HomeServiceRobot — ROS Noetic

A simulated home service robot built with ROS Noetic that autonomously navigates to pick up and deliver virtual objects in a Gazebo environment. The robot uses gmapping for SLAM, AMCL for localization, and move_base for autonomous navigation.

![ROS-Noetic](https://img.shields.io/badge/ROS-Noetic-blue)
![Gazebo](https://img.shields.io/badge/Simulation-Gazebo%2011-orange)
![Docker](https://img.shields.io/badge/Container-Docker-blue)

## Project Overview

The robot (TurtleBot2/Kobuki) performs the following pipeline:

1. **SLAM** — Drive the robot manually to build a map using gmapping
2. **Localization** — Use AMCL to localize within the saved map
3. **Navigation** — Send autonomous goals via move_base (Dijkstra + DWA planner)
4. **Pick & Deliver** — Navigate to a pickup zone, wait 5 seconds, then deliver to a drop off zone, with a virtual object visualized in RViz via markers

## Packages

| Package | Description |
|---|---|
| `turtlebot` / `turtlebot_apps` | TurtleBot2 core bringup, navigation, teleop |
| `turtlebot_simulator` | Gazebo simulation of TurtleBot2 |
| `turtlebot_interactions` | RViz launchers |
| `kobuki` / `kobuki_desktop` | Kobuki base drivers and Gazebo plugin |
| `kobuki_msgs` | Kobuki message types |
| `depthimage_to_laserscan` | Converts Kinect depth image to 2D laser scan |
| `slam_gmapping` | GMapping SLAM |
| `yujin_ocs` | Velocity multiplexer (cmd_vel_mux) |
| `pick_objects` | Sends autonomous pickup and drop off goals to move_base |
| `add_markers` | Subscribes to odometry and shows/hides virtual object marker in RViz |
| `map` | Saved map files (`my_map.yaml`, `my_map.pgm`, `perfect.world`) |
| `rvizConfig` | Custom RViz config with Marker display |
| `scripts` | Shell scripts to launch each project phase |

## Directory Structure

```text
src/
├── pick_objects/
│   └── src/pick_objects.cpp      # Autonomous navigation to pickup/dropoff
├── add_markers/
│   └── src/add_markers.cpp       # Virtual object marker (subscribes to /odom)
├── map/
│   ├── perfect.world             # Gazebo world
│   ├── my_map.yaml               # Saved SLAM map metadata
│   └── my_map.pgm                # Saved SLAM map image
├── rvizConfig/
│   └── home_service.rviz         # RViz config with Marker display
├── scripts/
│   ├── test_slam.sh              # Launch Gazebo + gmapping + teleop + RViz
│   ├── test_navigation.sh        # Launch Gazebo + AMCL + RViz
│   ├── pick_objects.sh           # Launch full stack + pick_objects node
│   ├── add_markers.sh            # Launch full stack + add_markers node
│   └── home_service.sh           # Full home service demo
├── turtlebot_simulator/          # Gazebo launch files
├── turtlebot_apps/               # Navigation params and launch files
└── ...                           # Other dependency packages
```

## Running with Docker

```bash
# Build image
docker build -t homeservicerobot-ros-noetic .

# Start container (X11 forwarded, workspace mounted)
sudo ./docker-run.sh

# Inside container — build workspace
cd /root/catkin_ws && catkin_make

# Source workspace
source devel/setup.bash
```

## Usage

All scripts are run **inside the Docker container**:

### 1. Build a map with SLAM
```bash
./src/scripts/test_slam.sh
```
Drive the robot with the teleop window. When done, save the map:
```bash
rosrun map_server map_saver -f /root/catkin_ws/src/map/my_map
```

### 2. Test navigation with AMCL
```bash
./src/scripts/test_navigation.sh
```
Use the **2D Nav Goal** button in RViz to send the robot to a location.

### 3. Test pick & drop off navigation
```bash
./src/scripts/pick_objects.sh
```
The robot autonomously navigates to the pickup zone `(2.99, -2.37)`, waits 5 seconds, then travels to the drop off zone `(3.74, -4.54)`.

### 4. Test virtual object markers
```bash
./src/scripts/add_markers.sh
```
A blue cube appears at the pickup zone, disappears when the robot arrives, and reappears at the drop off zone.

### 5. Full home service demo
```bash
./src/scripts/home_service.sh
```
Launches all nodes together. The robot navigates autonomously while the virtual object marker tracks its progress.

## Key Configuration Files

| File | Purpose |
|---|---|
| `turtlebot_apps/turtlebot_navigation/param/costmap_common_params.yaml` | Obstacle inflation radius, cost scaling |
| `turtlebot_apps/turtlebot_navigation/launch/includes/gmapping/kinect_gmapping.launch.xml` | GMapping SLAM parameters |
| `turtlebot_interactions/turtlebot_rviz_launchers/rviz/navigation.rviz` | Base RViz navigation config |
| `kobuki/kobuki_description/urdf/kobuki_gazebo.urdf.xacro` | Kobuki Gazebo plugin (TF, sensors) |

## Dependencies (installed in Docker image)

- `ros-noetic-navigation` (amcl, move-base, map-server)
- `ros-noetic-slam-gmapping`
- `ros-noetic-robot-state-publisher`
- `ros-noetic-gazebo-ros`
- `ros-noetic-rtabmap-ros`
- `ros-noetic-joy`
- `ros-noetic-xacro`
- ECL libraries (for Kobuki)


## Project Overview

The robot navigates a simulated 3-room indoor environment and builds a consistent map using:

- **Visual loop closure** — ORB feature matching with a bag-of-words vocabulary
- **ICP scan matching** — lidar-assisted constraint verification (`Reg/Strategy=2`)
- **g2o pose graph optimisation** — accurate trajectory correction on loop closure

### ROS Packages

| Package | Description |
|---|---|
| `my_robot` | Robot URDF (differential drive, Hokuyo lidar, RGB-D camera), Gazebo world |
| `slam` | RTAB-Map launch files and map storage |
| `localization` | AMCL-based localisation (uses pre-built map) |

## Directory Structure

```text
src/
├── my_robot/
│   ├── launch/          # world.launch, robot_description.launch
│   ├── urdf/            # my_robot.xacro, my_robot.gazebo
│   └── worlds/          # perfect.world (3-room indoor environment)
├── slam/
│   ├── launch/
│   │   └── mapping.launch   # RTAB-Map SLAM launch
│   └── maps/
│       └── rtabmap.db       # Persisted RTAB-Map database
└── localization/
    ├── config/          # Navigation YAML params
    └── launch/
```

> **Note:** `rtabmap.db` is too large to include in this repository.
> Download it from Google Drive: [rtabmap.db](https://drive.google.com/file/d/1-pLx8QG8IHFKXiHPNdW1Wh3KVvGIsJPN/view?usp=sharing)
> Place it at `src/slam/maps/rtabmap.db` before launching.

## Map Output

![RTAB-Map occupancy grid](Screenshot%20from%202026-05-01%2018-00-58.png)

## Loop Closure Results

The final mapping session produced the following closure statistics (from `rtabmap-info`):

| Link Type | Count | Description |
|---|---|---|
| Neighbor | 818 | Sequential odometry edges |
| **GlobalClosure** | **17** | Long-range loop closures detected by visual bag-of-words |
| **LocalSpaceClosure** | **708** | Short-range proximity closures from ICP scan matching |

A total of **725 loop closures** were detected over an 82.5 m trajectory (940 nodes), giving the pose graph optimizer strong constraints to produce a consistent, drift-free map.

## Running with Docker

```bash
# Build image
docker build -t mapmyworld-ros-noetic .

# Launch container (X11 forwarded)
./docker-run.sh

# Inside container — build workspace
cd /catkin_ws && catkin_make

# Launch Gazebo world
roslaunch my_robot world.launch

# In a second terminal — launch RTAB-Map
roslaunch slam mapping.launch
```

## Key SLAM Parameters

| Parameter | Value | Purpose |
|---|---|---|
| `Kp/DetectorStrategy` | 2 (ORB) | Fast, CPU-efficient features |
| `Kp/MaxFeatures` | 1000 | Large vocabulary for loop closure |
| `Reg/Strategy` | 2 (Visual+ICP) | Camera + lidar fusion |
| `Optimizer/Strategy` | 2 (g2o) | High-accuracy pose graph |
| `Rtabmap/DetectionRate` | 2 Hz | Fast node addition |

## References

- [RTAB-Map ROS wiki](http://wiki.ros.org/rtabmap_ros)
- [pgm_map_creator](https://github.com/JZX-MY/pgm_map_creator)

