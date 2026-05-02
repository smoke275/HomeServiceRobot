#include <ros/ros.h>
#include <visualization_msgs/Marker.h>
#include <nav_msgs/Odometry.h>
#include <cmath>

// Zone coordinates
const double PICKUP_X  = 2.99,  PICKUP_Y  = -2.37;
const double DROPOFF_X = 3.74,  DROPOFF_Y = -4.54;
const double THRESHOLD = 0.5;

enum State { GOING_TO_PICKUP, PICKED_UP, GOING_TO_DROPOFF, DROPPED_OFF };
State state = GOING_TO_PICKUP;

ros::Publisher marker_pub;

void publishMarker(double x, double y, uint32_t action)
{
  visualization_msgs::Marker marker;
  marker.header.frame_id = "map";
  marker.header.stamp = ros::Time::now();
  marker.ns = "add_markers";
  marker.id = 0;
  marker.type = visualization_msgs::Marker::CUBE;
  marker.action = action;
  marker.pose.position.x = x;
  marker.pose.position.y = y;
  marker.pose.orientation.w = 1.0;
  marker.scale.x = 0.3;
  marker.scale.y = 0.3;
  marker.scale.z = 0.3;
  marker.color.r = 0.0f;
  marker.color.g = 0.0f;
  marker.color.b = 1.0f;
  marker.color.a = 1.0;
  marker_pub.publish(marker);
}

void odomCallback(const nav_msgs::Odometry::ConstPtr& msg)
{
  double rx = msg->pose.pose.position.x;
  double ry = msg->pose.pose.position.y;

  if (state == GOING_TO_PICKUP)
  {
    double dist = std::sqrt(std::pow(rx - PICKUP_X, 2) + std::pow(ry - PICKUP_Y, 2));
    if (dist < THRESHOLD)
    {
      ROS_INFO("Reached pickup zone. Picking up object...");
      publishMarker(PICKUP_X, PICKUP_Y, visualization_msgs::Marker::DELETE);
      state = PICKED_UP;
      ros::Duration(5.0).sleep();
      ROS_INFO("Object picked up. Heading to drop off zone.");
      state = GOING_TO_DROPOFF;
    }
  }
  else if (state == GOING_TO_DROPOFF)
  {
    double dist = std::sqrt(std::pow(rx - DROPOFF_X, 2) + std::pow(ry - DROPOFF_Y, 2));
    if (dist < THRESHOLD)
    {
      ROS_INFO("Reached drop off zone. Object delivered.");
      publishMarker(DROPOFF_X, DROPOFF_Y, visualization_msgs::Marker::ADD);
      state = DROPPED_OFF;
    }
  }
}

int main(int argc, char** argv)
{
  ros::init(argc, argv, "add_markers");
  ros::NodeHandle n;

  marker_pub = n.advertise<visualization_msgs::Marker>("visualization_marker", 1);
  ros::Subscriber odom_sub = n.subscribe("/odom", 10, odomCallback);

  // Wait for rviz to subscribe
  ros::Rate r(10);
  while (marker_pub.getNumSubscribers() < 1)
  {
    if (!ros::ok()) return 0;
    ROS_WARN_ONCE("Waiting for a subscriber to the marker");
    r.sleep();
  }

  // Show marker at pickup zone initially
  publishMarker(PICKUP_X, PICKUP_Y, visualization_msgs::Marker::ADD);
  ROS_INFO("Marker published at pickup zone (%.2f, %.2f)", PICKUP_X, PICKUP_Y);

  ros::spin();
  return 0;
}
