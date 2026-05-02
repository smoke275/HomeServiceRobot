# MapMyWorld - ROS RTAB-Map SLAM

A ROS Noetic project using **RTAB-Map** (Real-Time Appearance-Based Mapping) to build a 3D map of an indoor environment. The robot uses an RGB-D camera and a Hokuyo lidar to perform simultaneous localisation and mapping (SLAM) with visual loop closure detection.

![ROS-Noetic](https://img.shields.io/badge/ROS-Noetic-blue)
![Gazebo](https://img.shields.io/badge/Simulation-Gazebo%2011-orange)
![RTAB-Map](https://img.shields.io/badge/SLAM-RTAB--Map%200.21-green)

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

