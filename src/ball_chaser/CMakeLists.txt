cmake_minimum_required(VERSION 3.0.2)
project(ball_chaser)

## Compile as C++11
add_compile_options(-std=c++11)

## Find catkin macros and libraries
## Added geometry_msgs because your code uses Twist messages
find_package(catkin REQUIRED COMPONENTS
  message_generation
  roscpp
  std_msgs
  geometry_msgs
)

################################################
## Declare ROS messages, services and actions ##
################################################

## Generate services in the 'srv' folder
add_service_files(
  FILES
  DriveToTarget.srv
)

## Generate added messages and services with any dependencies listed here
generate_messages(
  DEPENDENCIES
  std_msgs
)

###################################
## catkin specific configuration ##
###################################
catkin_package(
#  CATKIN_DEPENDS message_runtime roscpp std_msgs geometry_msgs
)

###########
## Build ##
###########

## Specify additional locations of header files
include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

## ====================================
## DRIVE_BOT NODE CONFIGURATION
## ====================================

# Movement Controller Node
add_executable(drive_bot src/drive_bot.cpp)
target_link_libraries(drive_bot ${catkin_LIBRARIES})
add_dependencies(drive_bot ball_chaser_generate_messages_cpp)

# Process Image Node
add_executable(process_image src/process_image.cpp)
target_link_libraries(process_image ${catkin_LIBRARIES})
add_dependencies(process_image ball_chaser_generate_messages_cpp)
