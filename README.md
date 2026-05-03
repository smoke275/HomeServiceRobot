# Home Service Robot — ROS Noetic

A simulated home service robot built with ROS Noetic. The robot uses **gmapping** for SLAM, **AMCL** for localization, and **move_base** for autonomous navigation. It picks up and delivers a virtual object in a Gazebo environment, visualized in RViz via interactive markers.

![ROS-Noetic](https://img.shields.io/badge/ROS-Noetic-blue)
![Gazebo](https://img.shields.io/badge/Simulation-Gazebo%2011-orange)
![Docker](https://img.shields.io/badge/Container-Docker-blue)

---

## Project Overview

The robot (TurtleBot2/Kobuki with Kinect depth sensor) performs the following sequence:

1. **SLAM** — Build a map by manually driving the robot with `test_slam.sh`
2. **Localization** — Localize within the saved map using AMCL (`test_navigation.sh`)
3. **Navigation** — Send autonomous goals via move_base (`pick_objects.sh`)
4. **Home Service** — Navigate to pickup zone, hide marker, wait 5 s, navigate to drop-off zone, show marker (`home_service.sh`)

---

## Packages Used

### Localization — AMCL

**Package:** `ros-noetic-amcl`

Adaptive Monte Carlo Localization (AMCL) is a probabilistic localization algorithm. It uses a particle filter to track the robot position against a pre-built 2D occupancy grid map. Sensor measurements from the Kinect depth camera (converted to a laser scan by `depthimage_to_laserscan`) are compared against the map to weight and resample the particle distribution. Over time the particle cloud converges to the robot true pose.

Configuration lives in `turtlebot_apps/turtlebot_navigation/param/`.

### Mapping — gmapping

**Package:** `ros-noetic-slam-gmapping`

GMapping implements a Rao-Blackwellized particle filter SLAM algorithm. Each particle carries an independent map hypothesis and a robot trajectory estimate. Laser scan observations update the per-particle maps and resampling keeps the most probable hypotheses. The output is a 2D occupancy grid published on `/map`.

Parameters are tuned in `turtlebot_apps/turtlebot_navigation/param/gmapping_params.yaml`:
- `particles: 200` — particle count balancing accuracy vs CPU
- `minimumScore: 30` — scan-matching quality threshold
- `iterations: 10` — ICP iterations per scan
- `maxUrange: 5.5` / `maxRange: 8.0` — effective sensor range

### Navigation — move_base + DWA Planner

**Package:** `ros-noetic-move-base`

`move_base` provides a ROS action interface for 2D goal navigation. It combines:
- **Global planner** (Dijkstra/A*) — computes a path on the static costmap
- **Local planner** (DWA — Dynamic Window Approach) — generates velocity commands to follow the path while avoiding obstacles in real time

The costmap is populated by the Kinect depth-to-laser scan and inflated around obstacles. Parameters are in `turtlebot_apps/turtlebot_navigation/param/`.

### Virtual Object — RViz Markers

**Package:** `add_markers` (custom, `src/add_markers/`)

Uses `visualization_msgs/Marker` to display a blue cube in RViz. The node subscribes to `/odom` and tracks the robot proximity to the pickup and drop-off zones, showing and hiding the marker to simulate object pickup and delivery.

### Autonomous Navigation — pick_objects

**Package:** `pick_objects` (custom, `src/pick_objects/`)

Sends `move_base_msgs/MoveBaseGoal` action goals to `move_base`. On reaching the pickup zone it prints "Reached pickup zone", waits 5 seconds to simulate loading, then navigates to the drop-off zone and prints "Reached drop-off zone".

---

## Repository Structure

```
src/
├── pick_objects/
│   └── src/pick_objects.cpp      # Autonomous navigation to pickup/drop-off
├── add_markers/
│   └── src/add_markers.cpp       # Virtual object marker controller
├── map/
│   ├── perfect.world             # Gazebo simulation world
│   ├── my_map.yaml               # Saved SLAM map (metadata)
│   └── my_map.pgm                # Saved SLAM map (image)
├── rvizConfig/
│   └── home_service.rviz         # RViz config with Marker display
├── scripts/
│   ├── test_slam.sh              # Gazebo + gmapping + teleop + RViz
│   ├── test_navigation.sh        # Gazebo + AMCL + move_base + RViz
│   ├── pick_objects.sh           # Full stack + pick_objects node
│   ├── add_markers.sh            # Full stack + add_markers node
│   └── home_service.sh           # Full home service demo
├── turtlebot_simulator/          # Gazebo launch files for TurtleBot2
├── turtlebot_apps/               # Navigation params and launch files
│   └── turtlebot_navigation/
│       └── param/
│           ├── gmapping_params.yaml
│           ├── move_base_params.yaml
│           ├── dwa_local_planner_params.yaml
│           └── costmap_common_params.yaml
└── turtlebot_interactions/       # RViz launcher and configs
```

---

## Running with Docker

```bash
# Build the image
sudo docker build -t homeservicerobot-ros-noetic .

# Start the container (X11 forwarded, workspace mounted)
sudo ./docker-run.sh

# Inside the container — build the workspace
cd /root/catkin_ws && catkin_make
source devel/setup.bash
```

---

## Shell Scripts

All scripts are run from `/root/catkin_ws` **inside the Docker container**.

### 1. Build a map with SLAM

```bash
./src/scripts/test_slam.sh
```

Launches Gazebo, `slam_gmapping`, `teleop_twist_keyboard`, and RViz. Drive the robot to explore the environment. When done, save the map:

```bash
rosrun map_server map_saver -f /root/catkin_ws/src/map/my_map
```

### 2. Test autonomous navigation

```bash
./src/scripts/test_navigation.sh
```

Launches Gazebo, AMCL, move_base, and RViz. Use the **2D Nav Goal** button in RViz to command the robot to any pose.

### 3. Autonomous pick and drop-off

```bash
./src/scripts/pick_objects.sh
```

The `pick_objects` node sends two sequential goals to `move_base`:
- **Pickup zone** — robot arrives, prints "Reached pickup zone", waits 5 s
- **Drop-off zone** — robot arrives, prints "Reached drop-off zone"

### 4. Virtual object markers

```bash
./src/scripts/add_markers.sh
```

A blue cube appears at the pickup zone on startup. It disappears when the robot reaches the pickup zone (simulating pickup), then reappears at the drop-off zone (simulating delivery).

### 5. Full home service demo

```bash
./src/scripts/home_service.sh
```

Launches all nodes together. The robot navigates autonomously while the virtual object marker tracks the pickup and delivery sequence.

---

## Key Configuration Files

| File | Purpose |
|---|---|
| `turtlebot_apps/turtlebot_navigation/param/gmapping_params.yaml` | GMapping SLAM tuning |
| `turtlebot_apps/turtlebot_navigation/param/move_base_params.yaml` | move_base timeouts and recovery |
| `turtlebot_apps/turtlebot_navigation/param/dwa_local_planner_params.yaml` | DWA velocity and tolerance params |
| `turtlebot_apps/turtlebot_navigation/param/costmap_common_params.yaml` | Obstacle inflation radius |
| `rvizConfig/home_service.rviz` | RViz config with Marker display |

---

## Dependencies

Installed automatically via the Dockerfile:

| Package | Role |
|---|---|
| `ros-noetic-navigation` | AMCL, move_base, map_server, costmap |
| `ros-noetic-slam-gmapping` | GMapping SLAM |
| `ros-noetic-gazebo-ros-pkgs` | Gazebo-ROS bridge |
| `ros-noetic-robot-state-publisher` | TF tree from URDF |
| `ros-noetic-teleop-twist-keyboard` | Manual keyboard teleop |
| `ros-noetic-explore-lite` | Frontier-based autonomous exploration |
| `depthimage_to_laserscan` | Kinect depth to 2D laser scan for gmapping/AMCL |
