#include <ros/ros.h>
#include <move_base_msgs/MoveBaseAction.h>
#include <actionlib/client/simple_action_client.h>

typedef actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> MoveBaseClient;

int main(int argc, char** argv)
{
  ros::init(argc, argv, "pick_objects");

  MoveBaseClient ac("move_base", true);

  while (!ac.waitForServer(ros::Duration(5.0)))
    ROS_INFO("Waiting for the move_base action server to come up");

  move_base_msgs::MoveBaseGoal goal;
  goal.target_pose.header.frame_id = "map";
  goal.target_pose.header.stamp = ros::Time::now();

  // Pickup zone
  goal.target_pose.pose.position.x = 2.99;
  goal.target_pose.pose.position.y = -2.37;
  goal.target_pose.pose.orientation.w = 1.0;

  ROS_INFO("Sending robot to pickup zone");
  ac.sendGoal(goal);
  ac.waitForResult();

  if (ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED)
    ROS_INFO("Reached pickup zone");
  else
  {
    ROS_WARN("Failed to reach pickup zone");
    return 1;
  }

  ros::Duration(5.0).sleep();

  // Drop off zone
  goal.target_pose.header.stamp = ros::Time::now();
  goal.target_pose.pose.position.x = 0.32;
  goal.target_pose.pose.position.y = -4.10;
  goal.target_pose.pose.orientation.w = 1.0;

  ROS_INFO("Sending robot to drop off zone");
  ac.sendGoal(goal);
  ac.waitForResult();

  if (ac.getState() == actionlib::SimpleClientGoalState::SUCCEEDED)
    ROS_INFO("Reached drop off zone");
  else
    ROS_WARN("Failed to reach drop off zone");

  return 0;
}
