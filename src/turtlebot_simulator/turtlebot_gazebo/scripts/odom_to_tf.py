#!/usr/bin/env python3
"""Relay /odom odometry messages as odom -> base_footprint TF transform."""
import rospy
import tf
from nav_msgs.msg import Odometry


def odom_callback(msg):
    br.sendTransform(
        (msg.pose.pose.position.x,
         msg.pose.pose.position.y,
         msg.pose.pose.position.z),
        (msg.pose.pose.orientation.x,
         msg.pose.pose.orientation.y,
         msg.pose.pose.orientation.z,
         msg.pose.pose.orientation.w),
        msg.header.stamp,
        "base_footprint",
        "odom"
    )


rospy.init_node('odom_to_tf')
br = tf.TransformBroadcaster()
rospy.Subscriber('/odom', Odometry, odom_callback)
rospy.spin()
